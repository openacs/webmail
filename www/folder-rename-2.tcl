# /webmail/www/folder-rename-2.tcl

ad_page_contract {
    Rename a folder specified by mailbox_id and return to folder-index

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-15
    @cvs-id $Id$
} {
    { action2 "" }
    { folder_name "" }
    mailbox_id:integer
}

if { [string equal $action2 "Cancel"] 
     || [empty_string_p $folder_name] } {
    ad_returnredirect "folder-index"
    ad_script_abort
}

if { [string length $folder_name] > 50 } {
    wm_return_error "The folder name you entered ($folder_name) was invalid.  Please hit back and try again (the length limit is 50 characters)"
    ad_script_abort
} 

set user_id [ad_maybe_redirect_for_registration]
set name [wm_mailbox_verify_and_get_name $mailbox_id $user_id]

if { [wm_mailbox_name_reserved $name] } {
    wm_return_error "You are not allowed to rename the following mailboxes:
    [wm_mailbox_name_for_display INBOX], [wm_mailbox_name_for_display DRAFTS], [wm_mailbox_name_for_display SENT], [wm_mailbox_name_for_display TRASH], and SYSTEM."
    ad_script_abort
}

with_catch errmsg {
    db_dml folder_rename "
    UPDATE wm_mailboxes SET name=[ns_dbquotevalue $folder_name]
    WHERE mailbox_id=:mailbox_id"
} {
    wm_return_error "There was an error renaming your folder.  Most likely a folder with the same name already exists."
    ad_script_abort
}

ad_returnredirect "folder-index"
ad_script_abort
ad_set_client_property -persistent f "webmail" "mailbox_list" ""


