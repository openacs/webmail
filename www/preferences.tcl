# /webmail/www/preferences.tcl

ad_page_contract {
    Sets user's preferences.

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-10-10
    @cvs-id $Id$
} {
    { mailbox_id:integer "" }
} -properties {
    context:onevalue
    auto_save_p:onevalue
    confirmation_p:onevalue
    signature_p:onevalue
    delete_move_index_p:onevalue
    forward_p:onevalue
    reply_to:onevalue
    forward_address:onevalue
    client_time_zone:onevalue
    timezones:multirow
}


set user_id [ad_conn user_id]

set preferences_query "SELECT messages_per_page, signature_p,
                         forward_address, forward_p, auto_save_p,
                         confirmation_p, reply_to, from_name,
                         delete_move_index_p, client_time_zone
                       FROM wm_preferences 
                       WHERE user_id = :user_id"


if { ![db_0or1row get_preferences $preferences_query] } {
    wm_return_error "You do not have a preferences entry in the database.  That is bad.  Ask your sysadmin for one."
    return
}

template::multirow create timezones tz entry

with_catch errmsg {
    set tz_list [lc_list_all_timezones]
} {
    set tz_list [list]
}

set client_offset ""
foreach {entry} $tz_list {
    set tz [lindex $entry 0]
    set offset [lindex $entry 1]
    regsub {([-+][0-9][0-9])([0-9][0-9])[0-9]*} $offset {\1:\2} offset
    if { [string equal $client_time_zone $tz] } {
	set client_offset $offset
    }
    template::multirow append timezones $tz "$tz $offset"
}


set context [ad_context_bar_ws [list "index?[export_url_vars mailbox_id]" "Webmail"] "Preferences"]

ad_return_template
return
