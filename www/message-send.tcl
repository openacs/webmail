# /webmail/www/message-send.tcl

ad_page_contract {
    Present form to send message, populating certain fields if this is a response.

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-19
    @cvs-id $Id$
} {
    { response_to_msg_id:integer "" }
    { respond_to_all:integer 0 }
    { return_url "" }
    { forward_msg_id:integer "" }
    { forward_style "attachment" }
    { saved_draft_id:integer "" }
    { to:allhtml "" }
} -properties {
    msg_body:onevalue
    subject:onevalue
    page_title:onevalue
    signature_html_p:onevalue
    cc:onevalue
    bcc:onevalue
    from:onevalue
    email_in:onevalue
    context:onevalue
    to:onevalue
    signature:onevalue
}

# If response_to_msg_id is supplied, this is a response to the given msg_id.
# If forward_msg_id is supplied, we will forward that message as an attachment
# If respond_to_all is set to a true value, all recipients will be Cc'ed.

set msg_body ""
set subject ""
set page_title "Send Mail"
set signature_html_p ""
set cc ""
set bcc ""

set user_id [ad_maybe_redirect_for_registration]

set from [db_string wm_email "
                  SELECT email_user_name 
                         || '@' || full_domain_name
                    AS from_address
                    FROM wm_email_user_map eum, wm_domains d
                    WHERE eum.user_id = :user_id
                    AND eum.domain = d.short_name"]

if { ![empty_string_p $response_to_msg_id] } {

    if { ![wm_msg_permission $response_to_msg_id $user_id] } {
	wm_return_error "Error: Permission Denied
        You do not have permission to access this message to respond to it."
	return
    }

    set msg_body [db_string msg_response {
	SELECT webmail.get_response_text(:response_to_msg_id) FROM dual }]

    set subject [db_string response_msg_subject "
                 SELECT value FROM wm_headers
                 WHERE msg_id = :response_to_msg_id
                 AND lower(name)='subject'" -default ""]

    set page_title "Response to \"$subject\""
    if { ![regexp -nocase {^re:} $subject] } {
	set subject "Re: $subject"
    }
    
    set to [db_string msg_to {
	SELECT webmail.response_address(:response_to_msg_id) 
	FROM DUAL} -default ""]

	
    if { $respond_to_all } {
	# we have to get all recipients
	set respond_to_addresses [db_list msg_recipients {
	  SELECT value
	  FROM wm_headers
	  WHERE msg_id = :response_to_msg_id
	  AND (lower(name) = 'to'
	  OR lower(name) = 'cc') } ]

	set respond_to_addresses [split [join $respond_to_addresses ", "] ","]
	set cc [join [wm_remove_duplicate_emails -remove_list [list $from] $respond_to_addresses] ","]
    }
    set msg_body "$to wrote: \n[wm_quote_message $msg_body]"

}  elseif { ![empty_string_p $forward_msg_id] } {

    if { ![wm_msg_permission $forward_msg_id $user_id] } {
	wm_return_error "Permission Denied:
        You do not have permission to access this message."
	return
    }
    set subject [db_string forward_msg_subject "
                 SELECT value FROM wm_headers
                 WHERE msg_id = :forward_msg_id
                 AND lower(name)='subject'" -default ""]

    set subject "Fwd: $subject"
    
    set page_title "Forward message"
    if { $forward_style == "inline" } {
	set msg_body [db_string msg_response {
	    SELECT webmail.get_response_text(:forward_msg_id) FROM dual }]
	set msg_body [wm_quote_message $msg_body]
    }

} elseif { ![empty_string_p $saved_draft_id] } {

    if { ![wm_msg_permission $saved_draft_id $user_id] } {
	wm_return_error "Permission Denied:
        You do not have permission to access this message."
	return
    }
    db_foreach standard_headers {
      SELECT lower(name) AS name, value FROM wm_headers 
      WHERE lower(name) IN ('to','from','subject','cc','bcc') 
      AND msg_id = :saved_draft_id } {
	set $name $value
    }

    set msg_body [db_string saved_msg_body {
	SELECT body
	FROM wm_messages 
	WHERE msg_id = :saved_draft_id }]

}

set signature [wm_get_preference $user_id signature]
# We need to sub out certain characters that seem to mess
# up the javascript preview function
regsub -all {\"} $signature {\&#34;} signature
regsub -all {>} $signature {\&gt;} signature
set regexp [format {[%c%c]} 10 13]
regsub -all $regexp $signature {\&#10;} signature

set outgoing_msg_id [db_nextval wm_global_sequence]

db_dml msg_insert "INSERT INTO wm_outgoing_messages 
                   (outgoing_msg_id, user_id)
                   VALUES (:outgoing_msg_id, :user_id)"

set html_checked [db_string select_html_p {
    SELECT decode(signature_html_p,'t','checked','')
    FROM wm_preferences 
    WHERE user_id = :user_id }]

set signature_checked [ad_decode [wm_get_preference $user_id signature_p] \
                            "t" "checked" ""]
set html_checked [ad_decode [expr [string equal $html_checked "checked"] && \
	[string equal $signature_checked "checked"]] 1 checked ""]

set save_checked [ad_decode [wm_get_preference $user_id auto_save_p] \
                            "t" "checked" ""]

set context "[ad_context_bar_ws [list "index?[export_url_vars mailbox_id]" "Webmail"] "Message Compose"]"

ad_return_template 
return

