# /webmail/tcl/wm-util-procs.tcl
ad_library {
    Utility procs for webmail.
    <p>
    This is free software distributed under the terms of the GNU Public
    License.  Full text of the license is available from the GNU Project:
    http://www.fsf.org/copyleft/gpl.html

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2001-02-05
    @cvs-id $Id$

}


ad_proc wm_get_client_tz_offset { user_id } {
    @ returns The offset in hours between the client and the server.
} {
    set client_tz_offset [ad_get_client_property -default "" webmail client_tz_offset]
    if { [empty_string_p $client_tz_offset] } {
	set client_tz [wm_get_preference $user_id client_time_zone]
	with_catch errmsg {
	    set client_oracle_offset [db_string client_offset {
		SELECT ( (sysdate - timezone.local_to_utc (:client_tz, sysdate)) * 24 ) 
		FROM dual 
	    }]
	    set client_tz_offset [expr [lang::system::timezone_utc_offset] - $client_oracle_offset]
	} {
	    # They probably have not installed acs-lang; return no offset
	    return 0
	}
	ad_set_client_property -persistent f "webmail" "client_tz_offset" $client_tz_offset
    }
    return $client_tz_offset
}


ad_proc wm_mailbox_name_for_display { name } {
    The default mailboxes are always given the names INBOX, SENT, DRAFTS, TRASH in the database,
    however, the names which are displayed for these may be customized 
    by setting the package parameters.  For example, if you set the parameter TrashName to "Garbage," 
    this proc will return "Garbage" if given the input "TRASH."  
    Use this proc whenever displaying mailbox names to the user.
    @return The ad_parameter corresponding to the mailbox name, or if none exists, the mailbox name that was passed in.
} {
    switch $name {
	INBOX {
	    return [ad_parameter -package_id [wm_get_webmail_id] InboxName]
	}
	SENT {
	    return [ad_parameter -package_id [wm_get_webmail_id] SentName]
	}
	DRAFTS {
	    return [ad_parameter -package_id [wm_get_webmail_id] DraftsName]
	}
	TRASH {
	    return [ad_parameter -package_id [wm_get_webmail_id] TrashName]
	}
	default {
	    return $name
	}
    }
}


ad_proc wm_quote_message { msg_text } {
    @return Message quoted with ">" on each line
} {
    if { ![empty_string_p $msg_text] } {
	regsub -all "\n" $msg_text "\n> " quoted_text
	return ">$quoted_text"
    } else {
	return $msg_text
    }
}


ad_proc wm_clean_message_html { msg } {
    Removes bad html which can mess up the Webmail GUI.
    Removes the following: base tags, style tags, link tags, 
    and the bgcolor and background args to the body tag.
    @return The message with the offending tags removed.
} {
    regsub -all -nocase {(<[^a-z"<>-]*base[^>]*>)} $msg "" msg
    regsub -all -nocase {(<[^a-z"<>-]*body[^>]*)bgcolor[!"#-;=@-~]+([^>]*>)} $msg {\1 \2} msg
    regsub -all -nocase {(<[^a-z"<>-]*body[^>]*)background[!"#-;=@-~]+([^>]*>)} $msg {\1 \2} msg
    regsub -all -nocase {(<[^a-z"<>-]*link[^>]*>)} $msg "" msg
    regsub -all -nocase {(<[^a-z"<>-]*style[^>]*>.*<[^a-z"<>-]*/style[^>]*>)} $msg "" msg
    return $msg
}


ad_proc wm_remove_duplicate_emails { 
  { -remove_list [list] } 
  email_list } {
    @param remove_list A list of emails to remove from the return list--these
    must be simple email addresses (i.e. "foo@foo.com"; not "Name &lt;email>" values).
    @param email_list The list to search.
    @return Returns the list of emails w/ duplicates removed.
    Note that if the original list contains emails of the type
    "Name" <email>, the corresponding output will be similar (including both
    names and email), but only the actual email address will be checked.
} {
  set return_emails {}
  foreach email $email_list {
    set email [string trim $email]
    if { ![regexp {<([^>]+)>} $email match email_value] } {
      set email_value $email
    }
    set email_value [string trim $email_value]
    if { [lsearch -exact $remove_list $email_value] == -1 } {
      lappend remove_list $email_value
      lappend return_emails $email
    }
  }
  return $return_emails
}


ad_proc wm_update_current_messages { { -remove "t" } cur_msg_id } { 
    This proc goes through the current_messages client property 
    and removes the current message and returns the next in the list
    @param remove If "t", will remove the current message if it is in the list
    @return The next msg_id in the list or empty string if none.
} {
    set current_messages [ad_get_client_property "webmail" "current_messages"]
    set index [lsearch -regexp $current_messages "$cur_msg_id \[tfTF\] \[tfTF\]"]

    set next_msg [lindex [lindex $current_messages [expr $index + 1] ] 0]
    if { $remove == "t" } {
	set current_messages [lreplace $current_messages $index $index]
	ad_set_client_property -persistent f "webmail" "current_messages" $current_messages
    }
    return $next_msg
}


ad_proc wm_get_preference { {-default ""} user_id preference } {
    @return The value of the specified preference for specified user (empty string if none)
} {
    return [db_string wm_get_preference "
                     SELECT $preference 
                     FROM wm_preferences
                     WHERE user_id = :user_id" -default $default] 
}


ad_proc wm_select_default_mailbox { user_id } {
    sets the default mailbox (INBOX) using ad_set_client_property
    @return The mailbox_id of the default mailbox (INBOX) 
} {
    set mailbox_id [db_string mboxid {
	select mailbox_id
	from wm_mailboxes
	where user_id = :user_id
	and name = 'INBOX'} -default ""]
	if { $mailbox_id == "" } {
	    ad_return_warning "No Account" "You have not been set up with an email account on this system. Please contact the system administrator to hook you up and try again."
	ad_script_abort
    }
    ad_set_client_property -persistent f "webmail" "mailbox_id" $mailbox_id
    return $mailbox_id
}


ad_proc wm_get_message_headers { msg_id user_id header_display_style references_var content_types } {
    This proc returns the headers for the given msg_id and user_id.
    @param header_display_style Set this to short to restrict the headers to only the basic ones.
    @param references_var The name of the variable you want to store a list of message references in (taken from the "References" header.
    @param content_types The name of the variable you want the list of content-type headers stored in.
    @return A list of header value pairs.
} {
    set return_fields {}
    upvar $references_var rvar
    set rvar {}
    upvar $content_types c_types
    set c_types {}
    if { $header_display_style == "short" } {
	set header_restriction_clause " and lower(name) in ('cc', 'in-response-to', 'references', 'reply-to', 'to', 'from', 'subject', 'date', 'content-type')"
    } else {
	set header_restriction_clause ""
    }
    
    set header_fields [db_list_of_lists headers "
      SELECT lower(name), name, value
      FROM wm_headers
      WHERE msg_id = :msg_id$header_restriction_clause
      ORDER BY sort_order desc"]

    # Re-order four main headers to always be first
    set new_header_fields {}
    foreach name { from to subject date } {
	set pos [lsearch -regexp $header_fields "^${name} (.*)"]
	lappend new_header_fields [lindex $header_fields $pos]
	set header_fields [lreplace $header_fields $pos $pos]
    }
    set new_header_fields [concat $new_header_fields $header_fields]
    
    foreach field $new_header_fields {
	set lower_name [lindex $field 0]
	set name [lindex $field 1]
	set value [lindex $field 2]
	if { [empty_string_p $value] } { continue }
	if { [string equal $lower_name references] } {	
	    set count 0
	    while { [regexp {^\s*(<[^>]+>)\s*(.*)$} $value dummy message_id value] } {
		incr count
		db_foreach ref_msg_id {
		    select m.msg_id as ref_msg_id
		    from wm_messages m, wm_mailboxes mbx
		    where m.message_id = :message_id
		    and mbx.user_id = :user_id
		    and mbx.mailbox_id = m.mailbox_id
		} {
		    lappend rvar [list $count $ref_msg_id]
		    break
		}
	    }
	} else {
	    if { [string equal $lower_name "content-type"] } {
		lappend c_types $value
		if { $header_display_style != "short" } {
		    lappend return_fields [list $name $value]
		}
	    } else {    
		lappend return_fields [list $name $value]
	    }
	}
    }
    return $return_fields
}


ad_proc wm_get_mailbox_list { { user_id "" } } {
    This routine caches for increased performance.
    @param user_id If not supplied, it is gotten from the connection
    @return a list of id, name pairs of all the user's mailboxes
} {
    set mailbox_list [ad_get_client_property -default "" webmail mailbox_list]
    if { [empty_string_p $mailbox_list] } {
	if { [empty_string_p $user_id] } {
	    set user_id [ad_conn user_id]
	}
	set mailbox_list [db_list_of_lists wm_mailbox_name_ids {
	    SELECT mailbox_id, name FROM wm_mailboxes 
	    WHERE user_id=:user_id ORDER BY mailbox_id
	}]
	ad_set_client_property -persistent f "webmail" "mailbox_list" $mailbox_list
    }
    return $mailbox_list
}
 

ad_proc wm_message_navigation_links { current_msg_id } {
    @return HTML to provide navigation links for previous unread, previous,
    next, and next unread messages. If the next message is unread, only provides
    next unread link. Same for previous and previous unread. 
} {
    set current_messages [ad_get_client_property "webmail" "current_messages"]
    set prev_unread ""
    set prev ""
    set next_unread ""
    set next ""
    set looking_for_next_message_p 0
    set looking_for_next_unread_message_p 0
    set last_unread ""
    set last ""
    set index 0

    foreach message $current_messages {
        set msg_id [lindex $message 0]
        set seen_p [lindex $message 1]
        set deleted_p [lindex $message 2]
        if { $msg_id == $current_msg_id } {
            set prev_unread $last_unread
            set prev $last
            set looking_for_next_message_p 1
            set current_messages [lreplace $current_messages $index $index [list $msg_id "t" $deleted_p]]
            ad_set_client_property -persistent f "webmail" "current_messages" $current_messages
            continue
        }
        incr index
        if { $looking_for_next_unread_message_p } {
            if { $seen_p == "f" } {
                set next_unread $msg_id
                break
            }
	    continue
        }
        if { $looking_for_next_message_p } {
            set next $msg_id
            if { $seen_p == "f" } {
                set next_unread $msg_id
                break
	    }
	    set looking_for_next_unread_message_p 1
	    continue            
        }
        if { $seen_p == "f" } {
            set last_unread $msg_id
        }
        set last $msg_id
    }
    set nav_links {}
    return [list [list "Previous Unread" $prev_unread] \
	    [list "Previous" $prev] [list "Next" $next] \
	    [list "Next Unread" $next_unread] ] 
}
