# /webmail/www/folder-index.tcl

ad_page_contract {
    Displays a list of messages in a mailbox. Gives UI for selecting, deleting,
    reordering, and filtering.

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-15
    @cvs-id $Id$
} {
} -properties {
    folder_table:onevalue
    context:onevalue
    target:onevalue
    mailboxes:multirow
    message_total:onevalue
    size_total:onevalue
}

template::multirow create mailboxes mailbox_id name num_msgs total_size reserved


set user_id [ad_maybe_redirect_for_registration]

set context "[ad_context_bar_ws [list "index?[export_url_vars mailbox_id]" "Webmail"] "Manage Folders"]" 

# If you don't do the users_folders query seperately,
# Oracle does it for each row in the second query, 
# thus slowing things down big time
set users_folders [join [db_list users_folders "
SELECT mailbox_id FROM wm_mailboxes WHERE user_id=:user_id"] ","]

set folder_query "
SELECT mb.mailbox_id, mb.name, nvl(mv1.num_total,0) as num_msgs,
        nvl(mv2.total_size,0) as total_size
      FROM wm_mailboxes mb, 
        (SELECT count(1) as num_total, mailbox_id
          FROM wm_messages
          WHERE mailbox_id in 
            ($users_folders)
          GROUP BY mailbox_id) mv1,
        (SELECT sum(nvl(msg_size,0)) as total_size, mailbox_id
          FROM wm_messages
          WHERE mailbox_id in 
            ($users_folders)
          GROUP BY mailbox_id) mv2
      WHERE mv1.mailbox_id(+)=mb.mailbox_id
        AND mv2.mailbox_id(+)=mb.mailbox_id
        AND user_id=:user_id
        ORDER BY mb.mailbox_id"

set message_total 0
set size_total 0

db_foreach folder_query $folder_query {
    set reserved [wm_mailbox_name_reserved $name]
    template::multirow append mailboxes $mailbox_id [wm_mailbox_name_for_display $name] [util_commify_number $num_msgs] [util_commify_number $total_size] $reserved
    set message_total [expr $message_total + $num_msgs]
    set size_total [expr $total_size + $size_total]
}

set message_total [util_commify_number $message_total]
set size_total [util_commify_number $size_total]

set target "folder-index.tcl"

ad_return_template 




