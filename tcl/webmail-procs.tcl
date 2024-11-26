# /webmail/tcl/webmail-procs.tcl

ad_library {
    General procs for webmail.
    <p>
    This is free software distributed under the terms of the GNU Public
    License.  Full text of the license is available from the GNU Project:
    http://www.fsf.org/copyleft/gpl.html

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$

}


ad_proc wm_get_mount_point {} {
    This is a singleton package, and there should only be one mount point
    @return The mount point of the webmail package 
} {
    return [db_string wm_get_mount_point {
	SELECT site_node.url(
	  (SELECT node_id FROM site_nodes
	    WHERE object_id=
              (SELECT package_id FROM apm_packages
	        WHERE package_key = 'webmail')
	  )
        ) FROM dual}]
}


ad_proc wm_get_alias_filename { short_name username } {
    @return The filename for the given user's alias file (including full path)
} {
    # qmail requires we substitute '.' in aliases with ':'
    regsub {\.} $username ":" alias_name
    return "[ad_parameter -package_id [wm_get_webmail_id] AliasDirectory].qmail-[string tolower $short_name]-[string tolower $alias_name]"
}


ad_proc wm_mailbox_name_reserved { name } {
    Checks if the given name is valid for a mailbox or whether it is reserved.
    @return 1 if reserved, 0 if not.
} {
    if { [string equal $name "INBOX"] || [string equal $name "DRAFTS"] || [string equal $name "SENT"] || [string equal $name "TRASH"] || [string equal $name "SYSTEM"] } {
	return 1
    } else {
	return 0
    }
}


ad_proc wm_add_user { user_id username short_name } {
    Creates a new webmail account for the given user_id
    Their account will have the address username@domain
    where domain is the domain specified by the domain's short_name.
} {
    set full_domain_name [db_string full_domain_name {
	SELECT full_domain_name 
	FROM wm_domains 
	WHERE short_name=:short_name }]
    
    set delivery_address "$short_name-$username@$full_domain_name"
    
    db_transaction {
	db_dml add_user {
	    INSERT INTO wm_email_user_map 
	    (email_user_name, domain, delivery_address,  user_id)
	    VALUES (:username, :short_name, :delivery_address, :user_id)
	}
	foreach mailbox_name [list INBOX SENT DRAFTS TRASH] {
	    db_dml add_mailbox {
		INSERT INTO wm_mailboxes 
		(mailbox_id, name, user_id, 
		creation_date)
		VALUES 
		(wm_global_sequence.nextval,:mailbox_name, 
		:user_id, sysdate)
	    }
	}
	with_catch errmsg {
	    set client_tz [lang::system::timezone]
	} {
	    set client_tz "GMT"
	}
	db_dml add_preferences {
	    INSERT INTO wm_preferences
	    (user_id, from_name, client_time_zone)
	    SELECT user_id, person.name(:user_id), :client_tz
	    FROM users WHERE user_id = :user_id 
	} 
	
	# Create alias file for this user. 
	set alias_fp [open [wm_get_alias_filename $short_name $username] w 0644]
	puts $alias_fp [ad_parameter -package_id [wm_get_webmail_id] QueueDirectory]
	close $alias_fp
    } on_error {
	ad_return_error "Error Creating Email Account" "An error occurred while 
	trying to create the email account for $username@$full_domain_name:
	<pre>
	$errmsg
	</pre>
	"
	ad_script_abort
    }
}


ad_proc wm_delete_user { user_id } {
    deletes the user and their qmail alias including all their 
    messages and mailboxes
    @return Any error message that might have occurred, empty string if none.
} {
    with_catch errmsg {
	db_1row domain_and_user_name {
	    SELECT domain, email_user_name
	    FROM wm_email_user_map WHERE user_id=:user_id
	}
	set file_string [wm_get_alias_filename $domain $email_user_name]
	db_dml wm_delete_user {
	    begin 
	    webmail.delete_user(:user_id); 
	    end;
	}
	file delete $file_string
    } {
	return $errmsg
    }
    return ""
}


ad_proc wm_msg_permission { msg_id user_id } {   
    @return 1 if user has permission to access the message, 0 otherwise
} {
    return [ad_decode [db_string msg_count {
	SELECT count(1) FROM dual WHERE EXISTS 
	(SELECT 1 FROM wm_messages wm, wm_mailboxes m
	WHERE wm.mailbox_id = m.mailbox_id
	AND wm.msg_id = :msg_id
	AND m.user_id = :user_id) }] 0 0 1]
}

    
ad_proc wm_mailbox_verify_and_get_name { mailbox_id user_id } {
    @return Mailbox name if user has permission to access the mailbox, return error otherwise.
} {
    set mailbox_name [db_string wm_mailbox_name {
	SELECT name as folder_name
	FROM wm_mailboxes
	WHERE mailbox_id = :mailbox_id
	AND user_id = :user_id } -default ""]
    if { [empty_string_p $mailbox_name] } {
	wm_return_error { You have specified an invalid folder. }
	ad_script_abort
    } else {
	return $mailbox_name
    }
}


ad_proc wm_return_error { errmsg } {
    Just redirects to the webmail-error page
} {
    ad_returnredirect "webmail-error?[export_url_vars errmsg]"
}


ad_proc wm_format_for_seen_or_deleted { seen_p str } {
    @return The variable str in bold if unread, or in italics if empty
} {
    if { [string length $str] > 40 } { set str "[string range $str 0 37]..." }
    if [empty_string_p $str] {
	set result "<i>(empty)</i>"
    } else {
	set result $str
    }
    if { $seen_p == "f" } {
	set result "<b>$result</b>"
    }
    return $result
}


################### CACHE MESSAGE IDS ##################

ad_proc wm_build_cached_ids { mailbox_id mailbox_name orderby { view_sql "" } } { 
    This proc creates a list of message ids to be cached and used for the index view.
    Pass extra sql in view_sql to customize the "view", otherwise, it will just load messages from the given mailbox
    @return A list of lists containing the msg_id, seen_p, and deleted_p in the inner lists for all the messages in the specified mailbox or view_sql
} {
    if { [empty_string_p $view_sql] } {
	set view_sql "FROM wm_messages m WHERE m.mailbox_id = :mailbox_id"
    }

    # we set this to select different columns depending on the folder
    set email_title "Sender"
    set email_select "m.from_value"
    if { [string equal $mailbox_name "SENT"] ||
         [string equal $mailbox_name "DRAFTS"] } {
	set email_title "Recipient"
	set email_select "m.to_value"
    }

    # dummy table to get ad_order_by_from_sort_spec to work
    set table_def {
	{ seen_p "New" {} {} } 
	{ "" "&nbsp;" {} {} } 
	{ email_value "email" {} {} } 
	{ subject_value "Subject" {} {} } 
	{ msg_size "Size" {} {} } 
	{ date_value "Date" {} {} } 
    }    

    set sql "SELECT msg_id, seen_p, deleted_p FROM
         (SELECT m.msg_id, seen_p, deleted_p,
         lower($email_select) AS email_value
         $view_sql
         [ad_order_by_from_sort_spec $orderby $table_def])"
    
    return [db_list_of_lists accumulate_msg_ids $sql]
}

############## BUILD THE INDEX VIEW FROM CACHED MESSAGE IDS ######################

ad_proc wm_build_index_from_cache { 
    { -mailbox_id 0 } 
    { -view_id 0 } 
    { -mailbox_name "" } 
    { -tz_offset 0 }
    current_messages msg_per_page page_num orderby 
} { 
    Creates a table of the messages in the current view using the currently cached messages
    See index.tcl and index-view.tcl for use examples
} {
    global message_count
    set view_messages [list 0]
    set page_start [expr [expr $page_num - 1] * $msg_per_page]
    set page_messages [lrange $current_messages $page_start [expr $page_start + $msg_per_page - 1]]

    foreach message $page_messages {
	lappend view_messages [lindex $message 0]
	incr message_count
    }

    # set the links and select columns to match the mailbox we are in
    set email_title "Sender"
    set email_select "m.from_value"
    set email_link "<a href=message?view_id=$view_id&\[export_url_vars msg_id view_id\]>\[wm_format_for_seen_or_deleted \$seen_p \[philg_quote_double_quotes \$email_value\]\]</a>"

    if { [string equal $mailbox_name "SENT"] ||
         [string equal $mailbox_name "DRAFTS"] } {
	set email_title "Recipient"
	set email_select "m.to_value"
	set return_url "index?[export_url_vars mailbox_id]"
	if { [string equal $mailbox_name "DRAFTS"] } {
	    set email_link "<a href=message-send?saved_draft_id=\$msg_id&[export_url_vars return_url]>\[wm_format_for_seen_or_deleted \$seen_p \[philg_quote_double_quotes \$email_value]]</a>"
	}
    }
    
    # we must have the ad_table sort links redirect to pages which clear the cached message ids
    # otherwise the messages will be out of order
    if { $view_id == 0 } { 
	set order_target_url "clear-cache-mailbox"
    } else {
	set order_target_url "clear-cache-view"
    }

    # Use ad_table to generate a sortable html table for the list of messages.
    # Note that some elements of this table_def are evaluated
    # at creation, and some are evaluated by ad_table
    set table_def [list \
	    { seen_p "New" \
	    { seen_p $order } \
	    {<td align=center><font size=-1>[ad_decode $seen_p "f" \
	    "<img src=\"graphics/checkmark.gif\">" "&nbsp;"]</font></td> } } \
	    { "" "&nbsp;" \
	    {m.msg_id $order} \
	    {<td><font size=-1><input type=checkbox name=msg_ids value=$msg_id></font></td>} } \
	    [list email_value $email_title \
	    { email_value $order } \
	    "<td><font size=-1>$email_link</font></td>" ] \
	    { subject_value "Subject" \
	    { subject_value $order } \
	    { <td><font size=-1>[wm_format_for_seen_or_deleted $seen_p \
	    [ad_decode $subject_value "" "&nbsp;" $subject_value]]</font></td> } } \
	    { msg_size "Size" \
	    { msg_size $order } \
	    { <td align=center><font size=-1>[wm_format_for_seen_or_deleted $seen_p \
	    ${msg_size}k]</font></td> } } \
	    { date_value "Date" \
	    { date_value $order } \
	    { <td align=center><font size=-1>[wm_format_for_seen_or_deleted $seen_p \
	    $date_value]</font></td> } } ]
    
    
    set sql "SELECT m.msg_id, m.msg_size, m.date_value, m.seen_p,
               m.subject_value, $email_select as email_value,
               TO_CHAR(date_value - $tz_offset/24, 'YYYY-MM-DD HH24:MI') 
               as pretty_date_value
               FROM wm_messages m WHERE msg_id IN ([join $view_messages ","])
               [ad_order_by_from_sort_spec $orderby $table_def]"

    set sql "SELECT m.msg_id, m.msg_size, m.date_value, m.seen_p,
               m.subject_value, $email_select as email_value
               FROM wm_messages m WHERE msg_id IN ([join $view_messages ","])
               [ad_order_by_from_sort_spec $orderby $table_def]"

    with_catch errmsg {
	set message_headers [ad_table -Torder_target_url $order_target_url -Torderby $orderby -Ttable_extra_html "border=0 cellspacing=1 cellpadding=0 width=100%" -Tband_colors [list "\#ffffff" "\#f0f0f0"] -Trows_per_page 1000 -Tasc_order_img "<img src=graphics/up.gif alt=\"^\">" -Tdesc_order_img "<img src=graphics/down.gif alt=\"v\">" webmail_message_headers $sql $table_def]
    } {
	wm_return_error "An error occurred while trying to fetch your messages.
	<p>
	The error message received was:
	$errmsg
	"
	ad_script_abort
    }
    return $message_headers
}


