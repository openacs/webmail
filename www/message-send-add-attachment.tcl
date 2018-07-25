# /webmail/www/message-send-add-attachment.tcl
ad_page_contract {
    Script for adding attachments to messages.

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-26
    @cvs-id $Id$
} {
    outgoing_msg_id:integer,notnull
    {upload_file ""}
    {response_to_msg_id:integer ""}
}


set user_id [ad_conn user_id]

# Check permissions.
set creation_user [db_string message_creation_user "select user_id
                   from wm_outgoing_messages
                   where outgoing_msg_id = $outgoing_msg_id" -default ""]

if { $creation_user == "" } {
    set errmsg "The message to which you are attempting to attach a file 
is no longer valid.  Maybe you already sent it away, 
or you waited too long."
    ad_returnredirect "attachments-error?[export_url_vars errmsg outgoing_msg_id]"
    ad_script_abort
} elseif { $creation_user != $user_id } {
    set errmsg "You do not have permission to attach a file to this message."
    ad_returnredirect "attachments-error?[export_url_vars errmsg outgoing_msg_id]"
    ad_script_abort
}

if { [empty_string_p $upload_file] } {
    set errmsg "You must specify a file to attach."
    ad_returnredirect "attachments-error?[export_url_vars errmsg outgoing_msg_id]"
    ad_script_abort
}

set tmp_filename [ns_queryget upload_file.tmpfile]
set content_type [ns_guesstype $upload_file]

if { [empty_string_p $content_type] } {
    set content_type "application/octet-stream"
}
set file_name [ad_sanitize_filename $upload_file]

db_dml wm_add_attachment {
             INSERT INTO wm_outgoing_message_parts 
             (outgoing_msg_id, data, filename, content_type, sort_order)
             VALUES 
             (:outgoing_msg_id, empty_blob(), :filename, 
             :content_type, wm_global_sequence.nextval)
             RETURNING data INTO :1
} -blob_files [list $tmp_filename]


ad_returnredirect "message-send-attachments?[export_url_vars outgoing_msg_id]"








