# /webmail/www/message-send-attachments.tcl

ad_page_contract {
    Pop-up page for adding attachments to messages.

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-26
    @cvs-id $Id$
} {
    outgoing_msg_id:integer,notnull
} -properties {
    outgoing_msg_id:onevalue
    creation_user:onevalue
}

set user_id [ad_conn user_id]


set creation_user [db_string message_creation_user {
    SELECT user_id
    FROM wm_outgoing_messages
    WHERE outgoing_msg_id = :outgoing_msg_id } -default ""]

template::query attachments multirow {
    SELECT filename,
    CEIL(dbms_lob.getlength(data)/1024) 
    AS att_size, sort_order
    FROM wm_outgoing_message_parts
    WHERE outgoing_msg_id = :outgoing_msg_id
    ORDER BY sort_order 
}

ad_return_template









