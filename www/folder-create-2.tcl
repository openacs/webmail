# /webmail/www/folder-create-2.tcl

ad_page_contract {
    Create a new mailbox and return to specified target, or index.tcl.
    Passes along mailbox_id to the target.

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    folder_name:notnull,trim
    target:notnull
}

set user_id [ad_maybe_redirect_for_registration]

if { [string length $folder_name] > 50 } {
    wm_return_error "The folder name you entered ($folder_name) was invalid.  Please hit back and try again (the length limit is 50 characters)"
    ad_script_abort
} 

if { [string equal $folder_name SYSTEM] } {
    wm_return_error "We're sorry, you are not allowed to create a mailbox named SYSTEM.
Please hit back and try another name."
    ad_script_abort
}
db_transaction {
    set mailbox_id [db_nextval wm_global_sequence]
    db_dml folder_create {
	INSERT INTO wm_mailboxes (mailbox_id, name, user_id, creation_date)
	VALUES (:mailbox_id, :folder_name, :user_id, sysdate)
    }
} on_error {
    if { [regexp -nocase {WM_MAILBOXES_USER_NAME_UN} $errmsg] } {
	wm_return_error "A mailbox already exists with that name"
        ad_script_abort
    }
    wm_return_error "An error occured while trying to create your folder:
$errmsg
"
    ad_script_abort
}

ad_set_client_property -persistent f "webmail" "mailbox_list" ""
if { [regexp {\?} $target] } {
    ad_returnredirect "$target&[export_url_vars mailbox_id]"
} else {
    ad_returnredirect "$target?[export_url_vars mailbox_id]"
}
