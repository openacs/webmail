# /webmail/www/process-selected-messages.tcl

ad_page_contract {
    Delete or refile messages selected messages.

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    msg_ids:integer,optional,multiple
    action
    mailbox_id
    { return_url "clear-cache-mailbox" }
}

if { ![exists_and_not_null msg_ids] } {
    # nothing selected
    ad_returnredirect $return_url
    return
}

ad_set_client_property -persistent f "webmail" "selected_messages" $msg_ids

if { [string equal $mailbox_id "@NEW"] } {
    ad_returnredirect "folder-create.tcl?target=[ad_urlencode "refile-selected?[export_url_vars return_url]"]"
}

set user_id [ad_verify_and_get_user_id]

with_catch errmsg { 
    set trash_mailbox_id [db_string trash_mailbox_id "
                        SELECT mailbox_id
	                FROM wm_mailboxes 
	                WHERE user_id=:user_id 
	                AND name='TRASH'"]
} {
    wm_return_error "You do not have a 'TRASH' folder--this is a problem."
    return
}

wm_mailbox_verify_and_get_name $mailbox_id $user_id

if { [string equal $action "Delete"] } {
    set mailbox_id $trash_mailbox_id
}

# If we're moving to the trash, mark deleted, 
# otherwise mark not-deleted.
set deleted_p [ad_decode [expr $trash_mailbox_id == $mailbox_id] 1 "t" "f"]

with_catch errmsg {
    db_dml delete "UPDATE wm_messages
	           SET deleted_p = :deleted_p,
	           mailbox_id = :mailbox_id
	           WHERE msg_id IN ([join $msg_ids ","])
	           AND mailbox_id IN 
	           (SELECT mailbox_id FROM wm_mailboxes 
	           WHERE user_id = :user_id)"
} {
    wm_return_error "Refiling of messages failed:
$errmsg
"
    return
}	
	
ad_returnredirect $return_url



