# /webmail/www/message-remove-attachment.tcl

ad_page_contract {
    Remove attachment from message

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-26
    @cvs-id $Id$
} {
    outgoing_msg_id:integer,notnull
    { attachments:multiple,integer }
}

set user_id [ad_conn user_id]

foreach sort_order $attachments {
    if { [empty_string_p $sort_order] } { continue }

    set creation_user [db_string attachment_remove_select {
	select user_id from wm_outgoing_messages m
	where m.outgoing_msg_id = :outgoing_msg_id } -default ""]
    if { $creation_user!=$user_id } {
	doc_return 200 text/html "You are not the owner of this message."
        ad_script_abort
    }

    db_dml attachment_remove_dml {
	delete from wm_outgoing_message_parts where
	outgoing_msg_id = :outgoing_msg_id
	and sort_order = :sort_order
    }
}

ad_returnredirect "message-send-attachments?[export_url_vars outgoing_msg_id]"




