# /webmail/www/message-printable.tcl

ad_page_contract {
    Displays the headers and message body and nothing else..

    @param msg_id ID of message to display
    @param header_display_style can be "short" or "all"
    @param body_display_style can be "parsed" or "unparsed"
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2001-02-07
    @cvs-id $Id$
} {
    msg_id:integer
    { header_display_style "short" }
    { body_display_style "parsed" }
} -properties {
    msg_id:onevalue
    header_display_style:onevalue
    body_display_style:onevalue
    mime_message_p:onevalue
    final_msg_body:onevalue
    references:onevalue
    message_headers:onevalue
}

set user_id [auth::require_login]

if { ![wm_msg_permission $msg_id $user_id] } {
    wm_return_error "
The specified message could not be found.  Either you do not have permission 
to read this message, or it has been deleted."
    return
}

template::multirow create headers name value
template::multirow create refs count ref_msg_id
set message_headers [wm_get_message_headers $msg_id $user_id $header_display_style references content_list]

foreach header $message_headers {
    template::multirow append headers [lindex $header 0] [lindex $header 1]
}

foreach ref $references {
    template::multirow append refs [lindex $ref 0] [lindex $ref 1]
}

set mime_message_p 0

if { $body_display_style == "parsed" } {
    set msg_body [db_string mime_text {
	SELECT mime_text
	FROM wm_messages
	WHERE msg_id = :msg_id } ]
    if { $msg_body != "" } {
	set quoted_msg_body $msg_body
	set mime_message_p 1
	# Grab the att_id and filename from the MIME text.
	regsub -all "##wm_image: (\[0-9\]+) (\[^\n\]+)" $quoted_msg_body "<img src=\"parts/\\2?msg_id=$msg_id\\&att_id=\\1\">" final_msg_body
	regsub -all "##wm_part: (\[0-9\]+) (\[^\n\]+)" $final_msg_body "<b>Attachment:</b> <a href=\"parts/\\2?msg_id=$msg_id\\&att_id=\\1\">\\2</a>" final_msg_body
	# Try to get rid of html which messes up the webmail GUI
	set final_msg_body [wm_clean_message_html $final_msg_body]
    }
}

if { $body_display_style == "unparsed" || $msg_body == "" } {
    set msg_body [db_string body {
	SELECT body
	FROM wm_messages
	WHERE msg_id = :msg_id
    }]
    set final_msg_body "<pre>[ad_quotehtml $msg_body]</pre>"
    foreach content $content_list {
	if { [regexp {text/html} $content] } {	    
	    set final_msg_body [wm_clean_message_html $msg_body]
	}
    }
    
}

set final_msg_body [wrap_string $final_msg_body 80]

ad_return_template

