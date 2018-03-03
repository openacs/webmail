# /webmail/www/message-send-2.tcl

ad_page_contract {
    Send message or save draft 

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    outgoing_msg_id:integer,notnull
    action:notnull
    { response_to_msg_id:integer "" } 
    { forward_msg_id:integer "0" } 
    { to:allhtml "" }
    { cc:allhtml "" }
    { bcc:allhtml "" }
    { subject:allhtml "" }
    { from:allhtml "" }
    { body:allhtml "" }
    { save "" }
    { html_use "" }
    { signature_use "" }
    { return_url "" }
}

if { [string equal $action "Cancel"] } {
    ad_returnredirect $return_url
    ad_script_abort
} 

# from is reserved word in Oracle
set from_for_db $from

if { [empty_string_p $return_url] } {
    set return_url index
}

if { [empty_string_p $to] && [empty_string_p $cc] && [empty_string_p $bcc]  } {
    wm_return_error "You did not specify any recipients for your message."
    ad_script_abort
}

set user_id [ad_conn user_id]

set creation_user [db_string creation_user {
    SELECT user_id
    FROM wm_outgoing_messages
    WHERE outgoing_msg_id = :outgoing_msg_id} -default ""]
if { $creation_user != $user_id } {
    wm_return_error "We're sorry, but no such message exists. You may have taken to long to 
compose it and it got cleaned up."
    ad_script_abort
}

# only add signature if signature_use is checked and we're not saving a draft
if { [string equal $signature_use "on"] &&
     ![string equal $action "Save Draft"] } {
    set signature_text [ad_decode $signature_use "on" \
	               [db_string get_signature "SELECT 
	               NVL(signature,'') FROM wm_preferences
	               WHERE user_id = :user_id" -default ""] ""]
    append body [ad_decode [string compare $html_use "on"] 0 "<br><br>$signature_text" "\n\n$signature_text"]
}

set content_type [ad_decode [string equal $html_use "on"] 1 "text/html" ""] 

set reply_to [wm_get_preference $user_id reply_to]

# if we were in the sent or drafts mailboxes, we must reload to see saved messages
set cached_mailbox_id [ad_get_client_property "webmail" "mailbox_id"]
if { [db_string saved_or_draft_folder_count {
    SELECT count(1) FROM dual WHERE EXISTS 
    (SELECT 1 FROM wm_mailboxes 
    WHERE user_id = :user_id
    AND name in ('SENT','DRAFTS')
    AND mailbox_id = :cached_mailbox_id)
}] > 0 } {
    ad_set_client_property -persistent f "webmail" "mailbox_id" ""
}

set header_sort_key 0
set wm_err ""

################### START THE TRANSACTION ###################
db_transaction {
    set cleaned_body [ns_reflow_text -- $body]
    db_dml wm_update_message_body {
	UPDATE wm_outgoing_messages 
	SET body = empty_clob() 
	WHERE outgoing_msg_id = :outgoing_msg_id
	RETURNING body INTO :1
    } -clobs [list $cleaned_body]
    # Delete old headers in case the user hit back and 
    # is re-sending the message
    db_dml delete_headers {
	DELETE FROM wm_outgoing_headers 
	WHERE outgoing_msg_id=:outgoing_msg_id }
    # Validate the from field.
    if { [db_string from_user {
	SELECT count(1) FROM dual WHERE EXISTS 
	(SELECT 1 FROM wm_email_user_map eum, wm_domains d
	WHERE user_id = :user_id
	AND eum.domain = d.short_name
	AND email_user_name || '@' || full_domain_name = 
	:from_for_db) }] == 0 } {
	set wm_err "You cannot send email as \"$from_for_db\"."
	db_abort_transaction
        return
    }
    set full_from [wm_get_preference $user_id from_name]
    if { [empty_string_p $full_from] } {
	set full_from "<$from_for_db>"
    } else {
	set full_from "[wm_get_preference $user_id from_name] <$from_for_db>"
    }
    # Insert standard headers.
    foreach field_spec [list [list To $to] [list Cc $cc] [list Bcc $bcc] [list Subject $subject] [list From $full_from] [list "Content-Type" $content_type] [list "Reply-to" $reply_to]] {
	set name [lindex $field_spec 0]
	set value [lindex $field_spec 1]
	if { ![empty_string_p $value] } {
	    db_dml insert_outgoing_headers "
                               INSERT INTO wm_outgoing_headers 
		               (outgoing_msg_id, name, value, sort_order)
		               VALUES (:outgoing_msg_id, 
		               :name, :value, :header_sort_key)"
	    incr header_sort_key
	}
    }

    ################### SET UP REFERENCES FIELD FOR RESPONSE #########
    if { ![empty_string_p $response_to_msg_id] } {	
	if { ![wm_msg_permission $response_to_msg_id $user_id] } {
	    set wm_err "You do not have permission to access this message to respond to it."
	    db_abort_transaction
            return
	}
	set old_references [db_string old_references "
	                        SELECT value FROM wm_headers
	                        WHERE msg_id = :response_to_msg_id
	                        AND lower(name) = 'references'" -default ""]
	set old_message_id [db_string old_message_id "
	                        SELECT message_id FROM wm_messages
	                        WHERE msg_id = :response_to_msg_id" -default ""]
	set references [DoubleApos [string trim "$old_references $old_message_id"]]
	if { ![empty_string_p $references] } {
	    db_dml insert_references "INSERT INTO wm_outgoing_headers 
		               (outgoing_msg_id, name, value, sort_order)
		               VALUES (:outgoing_msg_id, 'References', 
		               :references, :header_sort_key)"
	    incr header_sort_key
	}


    # ATTACH FORWARDED MESSAGE 
    } elseif { $forward_msg_id > 0 } {
	if { ![wm_msg_permission $forward_msg_id $user_id] } {
	    set wm_err "You do not have permission to access this message to forward it."
	    db_abort_transaction
	    return
	}
	# The message is attached in the java webmail.compose_message by passing 
	# a forward_msg_id which is greater than 0
    }
    ############## SEND MESSAGE ##################
    if { [string equal $action "Send"] } {
	# this function (compose_message) is an sqlj function puts the 
	# message parts together, attaches a forwarded message, and sends via qmail
	db_dml wm_compose_message "begin webmail.compose_message(:outgoing_msg_id, :forward_msg_id); end;"
    }

    ################# SAVE MESSAGE IF NECESSARY ##################
    set save_folder ""
    if { [string equal $save "on"] } {
	set save_folder "SENT"
    } 
    if { [string equal $action "Save Draft"] } {
	set save_folder "DRAFTS"
    }
    if { ![empty_string_p $save_folder] } {
	# Save a copy of message
	set mailbox_id [db_string save_mailbox_id "
                        SELECT mailbox_id
	                FROM wm_mailboxes 
	                WHERE user_id=:user_id 
	                AND name = :save_folder" -default ""]
	if { ![empty_string_p $mailbox_id] } {
	    set sent_msg_id [db_nextval wm_global_sequence]
	    set save_headers_select "
	               SELECT lower(name) as lower_name, value
	               FROM wm_outgoing_headers 
	               WHERE lower(name) IN ('to','subject')
	               AND outgoing_msg_id=:outgoing_msg_id"
	    db_foreach save_headers_select $save_headers_select {
	        set ${lower_name}_value [string range $value 0 149]
	    }
	    if { [string compare $save_folder "SENT"]==0 } {
		# Add a note for each attachment -- so user can see that 
		# their attachment was actually sent.
		set attachment_list [db_list attachment_list "
                          SELECT filename FROM wm_outgoing_message_parts
                          WHERE outgoing_msg_id=:outgoing_msg_id"]
		if { [llength $attachment_list] > 0 } {
		    append cleaned_body [ad_decode [string compare $html_use "on"] 0 "<br><br>&lt;&lt;Attachments: [join $attachment_list ", "]>>" "\n\n<<Attachments: [join $attachment_list ", "]>>"]
		}

	    }
	    db_dml save_message "INSERT INTO wm_messages
	               (msg_id, body, msg_size, to_value, from_value,
	               subject_value, date_value, mailbox_id, draft_p, recent_p)
	               SELECT :sent_msg_id, :cleaned_body,
	          [expr ceil([expr ([string length $cleaned_body] + 1.0) / 1024])],
	               :to_value, :from_for_db, :subject_value, 
	               sysdate, :mailbox_id, 't', 'f'              
	               FROM dual"
	    db_dml save_headers "INSERT INTO wm_headers
	               (msg_id, name, value, sort_order)
	               SELECT :sent_msg_id, name, value, sort_order
	               FROM wm_outgoing_headers
	              WHERE outgoing_msg_id = :outgoing_msg_id"
	    with_catch errmsg {
	      set client_offset [wm_get_client_tz_offset $user_id]
	      set tz_string [db_string get_tz_offset {
		SELECT gmt_offset FROM timezones 
		WHERE tz = 
		(SELECT client_time_zone FROM wm_preferences 
	        WHERE user_id = :user_id) } ]
	      regsub {([-+][0-9][0-9])([0-9][0-9])[0-9]*} $tz_string {\1\2} tz_string
	    } {
	      # probably don't have acs-lang installed--set defaults
	      set client_offset 0
	      set tz_string ""
	    }
	      db_dml save_headers "INSERT INTO wm_headers
	               (msg_id, name, value, sort_order)
	               SELECT :sent_msg_id, 'Date', 
	               to_char(sysdate - :client_offset / 24,'YYYY-Mon-DD HH24:MI:SS ') 
	               || :tz_string, 100 FROM dual"
	}
    }

# We don't delete message because people might hit back to resend
# Let them get cleaned up by the scheduled proc.


############ FIGURE OUT WHERE WE SHOULD RETURN TO ###################
    if { [string equal $action "Save Draft"] } {
	ad_returnredirect $return_url
    } else {
	if { [wm_get_preference $user_id confirmation_p] == "t" } {
	    ad_returnredirect "message-send-confirmation?[export_url_vars return_url]"
	} else {
	    ad_returnredirect $return_url
	}
    }
} on_error {
    if { [empty_string_p $wm_err] } {
	wm_return_error "An error occured while composing your message: 
$errmsg"
    } else {
	wm_return_error "An error occured while composing your message: 
<b>$wm_err</b>"
    }
}
