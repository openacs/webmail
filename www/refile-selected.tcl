# /webmail/www/refile-selected.tcl

ad_page_contract {
    Perform bulk refiling of selected messages.

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    mailbox_id:integer
    { return_url "clear-cache-mailbox" }
}

set user_id [ad_verify_and_get_user_id]

set msg_ids [ad_get_client_property "webmail" "selected_messages"]

if { ![regexp {^[{} 0-9]+$} $msg_ids] } {
    wm_return_error "You have specified an invalid message."
    ad_script_abort
}

wm_mailbox_verify_and_get_name $mailbox_id $user_id 

with_catch errmsg {
    db_dml refile "update wm_messages
	           set mailbox_id = :mailbox_id
	           where msg_id in ([join $msg_ids ","])
	           and mailbox_id in (select mailbox_id from wm_mailboxes 
	           where user_id = :user_id)"
} {
    wm_return_error "Refiling Failed" "Refiling of messages failed:
$errmsg
"
    ad_script_abort
}

ad_returnredirect $return_url

