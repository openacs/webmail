# /webmail/www/util-pages/mailbox-options.tcl
# @author Erik Bielefeldt (erik@arsdigita.com)
# @creation-date 2001-01-05
# @cvs-id $Id$
#
# Parameters: 
#   { exclude_id "0" }
#   { select_id "" }
#   mailbox_id:multiple,integer
#
# Properties:
#   select_options:multirow
#   select_id:onevalue

if { ![exists_and_not_null exclude_id] } {
    set exclude_id 0
}
if { ![exists_and_not_null select_id] } {
    set select_id ""
}

template::multirow create select_options mailbox_id name

set mailbox_list [wm_get_mailbox_list]
foreach mailbox $mailbox_list {
    if { [lindex $mailbox 0] != $exclude_id } {
	template::multirow append select_options [lindex $mailbox 0] [wm_mailbox_name_for_display [lindex $mailbox 1]]
    }
}

ad_return_template
