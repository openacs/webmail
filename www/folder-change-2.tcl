# /webmail/www/folder-change-2.tcl

ad_page_contract {
    Process folder-change.tcl form data. (delete, or empty; rename is
    handled by folder-rename.tcl)

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-18
    @cvs-id $Id$
} {
    action:notnull
    action2:notnull
    mailbox_id:integer,notnull
    { target "folder-index" }
}

if { [string equal $action2 "Cancel"] } {
    ad_returnredirect "folder-index"
    return
} 

set user_id [ad_maybe_redirect_for_registration]
set folder_name [wm_mailbox_verify_and_get_name $mailbox_id $user_id]

if { [string equal $action "Delete"] } {
    if { [wm_mailbox_name_reserved $folder_name] } {
	wm_return_error "You are not allowed to delete the following mailboxes:
	[wm_mailbox_name_for_display INBOX], [wm_mailbox_name_for_display DRAFTS], [wm_mailbox_name_for_display SENT], [wm_mailbox_name_for_display TRASH] and SYSTEM."
	return
    }
    with_catch errmsg {
	db_dml folder_mailbox_delete "
	  begin webmail.delete_mailbox(:mailbox_id); end;"
    } {
	wm_return_error "There was an error deleting your folder: 
	
	$errmsg"
	return
    }
    ad_set_client_property -persistent f "webmail" "mailbox_list" ""
    ad_returnredirect "folder-index"
    return
} elseif { [string equal $action "Empty"] } {
    with_catch errmsg {
	db_dml folder_msg_delete {
	    begin webmail.empty_mailbox(:mailbox_id); end;
	}
    } {
	wm_return_error "There was an error deleting your folder: 
	
	$errmsg"
	return
    }
    ad_returnredirect $target
    return
}


