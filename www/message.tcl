# /webmail/www/message.tcl

ad_page_contract {
    Displays a single message.

    @param msg_id ID of message to display
    @param header_display_style can be "short" or "all"
    @param body_display_style can be "parsed" or "unparsed"
    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    msg_id:integer
    { view_id:integer 0}
    { header_display_style "short" }
    { body_display_style "parsed" }
} -properties {
    mailbox_name:onevalue
    msg_id:onevalue
    header_display_style:onevalue
    body_display_style:onevalue
    mime_message_p:onevalue
    final_msg_body:onevalue
    deleted_p:onevalue
    context:onevalue
    navlinks:multirow
    next_msg_id:onevalue
    mailbox_id:onevalue
    view_id:onevalue
    references:onevalue
    message_headers:onevalue
}

set user_id [ad_maybe_redirect_for_registration]

set return_url [ad_urlencode "message?[export_url_vars view_id msg_id]"]

set message_exists_p [db_0or1row mailbox_info {
    SELECT wm.mailbox_id, m.name AS mailbox_name, wm.deleted_p
    FROM wm_messages wm, wm_mailboxes m
    WHERE wm.msg_id = :msg_id
    AND wm.mailbox_id = m.mailbox_id
    AND m.user_id = :user_id}]

if { !$message_exists_p } {
    wm_return_error "
The specified message could not be found.  Either you do not have permission 
to read this message, or it has been deleted."
    return
}

set view_name ""
if { $view_id == -1 } {
    set view_name "Custom View"
} elseif { $view_id != 0 } {
    set view_name [db_string filter_name {
	SELECT name 
	FROM wm_filter_views 
	WHERE filter_id=:view_id} -default ""]
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
set msg_body [db_string mime_text {
    SELECT mime_text
    FROM wm_messages
    WHERE msg_id = :msg_id } ]
if { $msg_body != "" } {
    set mime_message_p 1
}

if { $body_display_style == "parsed" } {
    if { $mime_message_p } {
	set quoted_msg_body $msg_body
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
    #regsub -all -nocase {[^"=](http://[-A-z/.0-9?#_%=&:;]+)} $msg_body { <a href="\1">\1</a>} final_msg_body
    set final_msg_body "<pre>[ad_quotehtml $msg_body]</pre>"
    foreach content $content_list {
	if { [regexp {text/html} $content] } {	    
	    set final_msg_body [wm_clean_message_html $msg_body]
	}
    }
    
}

db_dml seen_p_update {
    UPDATE wm_messages
    SET seen_p = 't'
    WHERE msg_id = :msg_id
}

db_release_unused_handles


set mailbox_name [wm_mailbox_name_for_display $mailbox_name]
if { [empty_string_p $view_name] } {
    set context "[ad_context_bar_ws [list "index?[export_url_vars mailbox_id]&clear_cache=0" "Webmail ($mailbox_name)"] "One Message"]"
} else {
    set context "[ad_context_bar_ws [list "index-view?[export_url_vars view_id]" "Webmail View ($view_name)"] "One Message"]"
}

template::multirow create nav_links name msg_id
set links [wm_message_navigation_links $msg_id]
foreach link $links {
    template::multirow append nav_links [lindex $link 0] [lindex $link 1]
}
set next_msg_id [lindex [lindex $links 2] 1]

ad_return_template
return
