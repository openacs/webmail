# /webmail/www/message-process.tcl

ad_page_contract {
    Refile or delete a single message and display next unread, 
    undeleted message, or index if none exist.

    @param msg_id The ID of the msg we're re-filing
    @param mailbox_id The ID of the mailbox to which we're re-filing 
    the message. If this parameter is unspecified (e.g. empty_string) 
    we return a nice error telling the user to first pick a mailbox

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-19
    @cvs-id $Id$
} {
    msg_id:integer
    { mailbox_id:integer "" }
    { view_id:integer 0 }
    next_msg_id:integer
    action:notnull
}


set user_id [ad_conn user_id]

if { [empty_string_p $mailbox_id] && [string equal $action "Refile"] } {
    ad_return_complaint 1 "<li>You have to select a folder to which to refile this message."
    ad_script_abort
}

with_catch errmsg { 
    set trash_mailbox_id [db_string trash_mailbox_id "
                        SELECT mailbox_id
	                FROM wm_mailboxes 
	                WHERE user_id=:user_id 
	                AND name='TRASH'"]
} {
    wm_return_error "You do not have a '[wm_mailbox_name_for_display TRASH]' folder.  That is not good."
    ad_script_abort
}

if { [string equal $action "Delete"] } {
    set mailbox_id $trash_mailbox_id
}

# If we're moving to the trash, mark deleted, 
# otherwise mark not-deleted.
set deleted_p [ad_decode [expr $trash_mailbox_id == $mailbox_id] 1 "t" "f"]

with_catch errmsg {
    db_dml refile_msg {
	UPDATE wm_messages
	SET deleted_p = :deleted_p, mailbox_id = :mailbox_id
	WHERE msg_id = :msg_id AND mailbox_id in 
	(SELECT mailbox_id FROM wm_mailboxes 
	WHERE user_id = :user_id)}
} {
    wm_return_error "Refiling failed:
$errmsg
"
    ad_script_abort
}

set index_url "index"
if { $view_id != "0" } {
    set index_url "index-view?[export_url_vars view_id]"
} 

set current_messages [ad_get_client_property "webmail" "current_messages"]
set index [lsearch -regexp $current_messages "$msg_id \[tfTF\] \[tfTF\]"]
if { $view_id == "0" } {
    set current_messages [lreplace $current_messages $index $index]
    ad_set_client_property -persistent f "webmail" "current_messages" $current_messages
}

if { ( [string equal $action "Delete"] 
       && [wm_get_preference $user_id delete_move_index_p]=="t" ) 
     || $next_msg_id == "" } {
    ad_returnredirect $index_url
    ad_script_abort
}

ad_returnredirect "message?msg_id=$next_msg_id&view_id=$view_id"



