# /webmail/www/template-master.tcl

ad_page_contract {
    Sets up datasources for the master template

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-15
    @cvs-id $Id$
} {
} -properties {
    inbox_id:onevalue
    mailboxes:multirow
    views:multirow
}
# parameter received is $context
#

set user_id [ad_verify_and_get_user_id]

set show_mailbox_info [ad_parameter -package_id [wm_get_webmail_id] ShowMailboxInfo]
if { $show_mailbox_info == "f" } {
    template::multirow create mailboxes mailbox_id name
    set mailbox_list [wm_get_mailbox_list $user_id]
    foreach mailbox $mailbox_list {
	template::multirow append mailboxes [lindex $mailbox 0] \
		[wm_mailbox_name_for_display [lindex $mailbox 1]]
	if { [lindex $mailbox 1] == "INBOX" } {
	    set inbox_id [lindex $mailbox 0]
	}
    }
} else {
    # If you don't do the users_folders query seperately,
    # Oracle does it for each row in the second query, 
    # thus slowing things down big time
    set users_folders [join [db_list users_folders "
      SELECT mailbox_id FROM wm_mailboxes WHERE user_id=:user_id"] ","]

    set folder_query "
    SELECT mb.mailbox_id, mb.name, nvl(mv1.num_total,0) as num_total,
        nvl(mv2.num_unread,0) as num_unread
      FROM wm_mailboxes mb, 
        (SELECT count(1) as num_total, mailbox_id
          FROM wm_messages
          WHERE mailbox_id in 
            ($users_folders)
          GROUP BY mailbox_id) mv1,
        (SELECT count(1) as num_unread, mailbox_id
          FROM wm_messages
          WHERE mailbox_id in 
            ($users_folders)
            AND seen_p='f'
          GROUP BY mailbox_id) mv2
      WHERE mv1.mailbox_id(+)=mb.mailbox_id
        AND mv2.mailbox_id(+)=mb.mailbox_id
        AND user_id=:user_id
        ORDER BY mb.mailbox_id"

    template::multirow create mailboxes mailbox_id name unread total
    db_foreach folder_query $folder_query {
	template::multirow append mailboxes $mailbox_id [wm_mailbox_name_for_display $name] [util_commify_number $num_unread] [util_commify_number $num_total] 
	if { $name == "INBOX" } {
	    set inbox_id $mailbox_id
	}
    }
}


# set up views variable

set view_query {
    SELECT name, filter_id 
    FROM wm_filter_views
    WHERE user_id=:user_id
    ORDER BY name
}

template::multirow create views view_id name
db_foreach view_query $view_query {
    template::multirow append views $filter_id $name
}
