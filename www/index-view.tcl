# /webmail/www/index-view.tcl

ad_page_contract {
    Displays messages in a view, with controls for customizing it.
    
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-12-27
    @cvs-id $Id$
} {
    { orderby "" }
    { page_num:integer "" }
    { view_id:integer "0" }
    { customize "f" }
} -properties {
    customize:onevalue
    orderby:onevalue
    message_headers:onevalue
    n_unread_messages:onevalue
    n_messages:onevalue
    context:onevalue
    view_name:onevalue
    view_id:onevalue
    msg_per_page:onevalue
    page_num:onevalue
    url:onevalue
    n_messages_comma:onevalue
}

set user_id [ad_maybe_redirect_for_registration]

# Set the mailbox_id to 0 because we're in a view
ad_set_client_property -persistent f "webmail" mailbox_id ""

# CLEARING CACHED MESSAGES IDS:
# we clear when the orderby 
# has changed from the cached copy
set clear_cache 0

foreach property [list orderby page_num] {
    set value [set $property]
    set cached_value [ad_get_client_property "webmail" $property]
    if { [empty_string_p $value] } {
	set $property $cached_value
    } else {
	if { $cached_value != $value } {
	    ad_set_client_property -persistent f "webmail" $property $value
	    if { $property != "page_num" } {
		set clear_cache 1
	    }
	}
    }
}

if { [empty_string_p $orderby] } {
    set orderby "date_value"
}

set view_name [db_string view_name "SELECT name FROM wm_filter_views
                                    WHERE filter_id=:view_id" -default ""]
if { [empty_string_p $view_name] } {
    if { $view_id == -1 } {
	set view_name "Custom view"
    } else {
	wm_return_error "The view you have specified does not exist."
	return
    }
}

##################### BUILD MESSAGE TABLE #####################

# message_ids are saved and reloaded using the client_property "current_messages"
set current_messages [ad_get_client_property -default "" "webmail" "current_messages"]
global message_count
set message_count 0
set tz_offset [wm_get_client_tz_offset $user_id]
set msg_per_page [wm_get_preference -default 50 $user_id messages_per_page]

if { [string equal $current_messages ""] || $clear_cache } {
    set view_sql [wm_build_view_sql $user_id $view_id]
    set current_messages [list]
    set current_messages [wm_build_cached_ids "" "" $orderby $view_sql]
}

set n_messages [llength $current_messages]

# Here we check that the page_num is in bounds, and otherwise we set it to 1
set num_pages [expr $n_messages / $msg_per_page]
if { [expr $n_messages % $msg_per_page] != 0 } {
    incr num_pages
}
if { [empty_string_p $page_num] || $page_num > $num_pages } {
    set page_num 1
    ad_set_client_property -persistent f "webmail" "page_num" $page_num
}

ad_set_client_property -persistent f "webmail" "current_messages" $current_messages
if { [llength $current_messages] > 0 } {
    set message_headers [wm_build_index_from_cache -view_id $view_id -tz_offset $tz_offset $current_messages $msg_per_page $page_num $orderby]
}

db_release_unused_handles

# How many messages we have, and how many of those are unread.
set n_unread_messages 0
foreach message $current_messages {
    if { [lindex $message 1] == "f" } { incr n_unread_messages }
}

set n_messages_comma [util_commify_number $n_messages]
set n_unread_messages [util_commify_number $n_unread_messages]
set context [ad_context_bar_ws "WebMail"]
set url "index-view?[export_url_vars view_id]"
 
ad_return_template
return
