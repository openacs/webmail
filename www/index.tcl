# index.tcl

ad_page_contract {
    Displays a list of messages in a mailboxame. Gives UI for selecting, deleting,
    reordering, and filtering.
    
    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    { orderby "" }
    { mailbox_id:integer "" }
    { page_num:integer "" }
} -properties {
    mailbox_name:onevalue
    orderby:onevalue
    message_headers:onevalue
    n_unread_messages:onevalue
    n_messages:onevalue
    n_messages_comma:onevalue
    context:onevalue
    empty_trash_target:onevalue
    msg_per_page:onevalue
    page_num:onevalue
    url:onevalue
}

set user_id [auth::require_login]

# CLEARING CACHED MESSAGES IDS:
# we clear when either the mailbox_id or the orderby 
# has changed from the cached copy
set clear_cache 0

# If mailbox_id was specified, then store it as a session property if it is
# different from what we already have.

foreach property [list mailbox_id orderby page_num] {
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

if { [empty_string_p $mailbox_id] || 
    ![db_0or1row mailboxname {
	SELECT name as mailbox_name
	FROM wm_mailboxes
	WHERE mailbox_id = :mailbox_id
	AND user_id = :user_id
    }] } {
	set mailbox_id [wm_select_default_mailbox $user_id]
	set mailbox_name "INBOX"
	set clear_cache 1
}

###################### MAKE MESSAGE TABLE ##################

# message_ids are saved and reloaded using the client_property "current_messages"
global current_messages
set current_messages [ad_get_client_property  -default "" "webmail" "current_messages"]
global message_count
set message_count 0
set tz_offset [wm_get_client_tz_offset $user_id]
set msg_per_page [wm_get_preference -default 50 $user_id messages_per_page]
if { [empty_string_p $current_messages] || $clear_cache } {
    set current_messages [wm_build_cached_ids $mailbox_id $mailbox_name $orderby ""]
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
    set message_headers [wm_build_index_from_cache -mailbox_id $mailbox_id -mailbox_name $mailbox_name -tz_offset $tz_offset $current_messages $msg_per_page $page_num $orderby]
}

db_release_unused_handles

# How many unread messages?
set n_unread_messages 0
foreach message $current_messages {
    if { [lindex $message 1] == "f" } { incr n_unread_messages }
}

set n_messages_comma [util_commify_number $n_messages]
set n_unread_messages [util_commify_number $n_unread_messages]

set context [ad_context_bar_ws "WebMail"]
set empty_trash_target [ad_urlencode "clear-cache-mailbox?mailbox_id=$mailbox_id"]
set url "index" 
 
ad_return_template
