# /webmail/www/folder-change.tcl

ad_page_contract {
    Present form to rename, delete, or empty a folder.
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-18
    @cvs-id $Id$
} {
    action:notnull
    mailbox_id:notnull,integer
} -properties {
    context:onevalue
    folder_name:onevalue
    form_vars:onevalue
} -validate {
    action_valid -requires { action:notnull } {
	if { ![string equal $action "Empty"] 
             && ![string equal $action "Delete"]
             && ![string equal $action "Rename"] } {
	    ad_complain { You have entered an invalid action }
	}
    }
}

set user_id [auth::require_login]
set folder_name [wm_mailbox_verify_and_get_name $mailbox_id $user_id]

if { [string equal $action Empty]
     && [string equal $folder_name "TRASH"] } {
    set action2 "Empty"
    ad_returnredirect "folder-change-2?[export_url_vars action action2 mailbox_id]"
    ad_script_abort
}

set context "[ad_context_bar_ws [list "index?[export_url_vars mailbox_id]" "Webmail"] [list "folder-index" "Manage Folders"] "$action Folder"]"
set folder_name [wm_mailbox_name_for_display $folder_name]
set form_vars [export_form_vars action mailbox_id]

ad_return_template

