# /webmail/www/preferences-2.tcl

ad_page_contract {
    Sets user preferences.

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-10-10
    @cvs-id $Id$
} {
    { return_url index }
    messages_per_page:integer
    forward_address:trim
    from_name:trim
    reply_to:trim
    auto_save_p:notnull
    confirmation_p:notnull
    signature_p:notnull
    forward_p:notnull
    delete_move_index_p:notnull
    timezone:notnull
} -validate {
    reply_to_is_email -requires {reply_to:trim} {
	if { ![empty_string_p $reply_to] && 
             ![util_email_valid_p $reply_to] } {
	    ad_complain {You have entered an invalid reply-to email}
	}
    } 
    forward_address_is_email -requires {forward_address:trim} {
	if { ![empty_string_p $forward_address] && 
             ![util_email_valid_p $forward_address] } {
	    ad_complain {You have entered an invalid forward address}
	}
	if { [empty_string_p $forward_address] &&
	[string equal $forward_p "t"] } {
	    ad_complain {You did not specify an address to forward your mail to.}
	}
	# check for circular forwards...
	set user_id [ad_verify_and_get_user_id]
	set email_query "SELECT lower(email_user_name || '@' || 
                              full_domain_name) 
                           AS email_address
                         FROM wm_email_user_map m, wm_domains d
                         WHERE d.short_name = m.domain 
                           AND m.user_id = :user_id"
	db_foreach wm_get_all_emails $email_query {
	    if { [string equal [string tolower $forward_address] $email_address] } {
		ad_complain "The forwarding address $forward_address is 
                             not allowed (it is already linked to this 
                             account)."
		break
	    }
	}
    } 
    booleans_valid {
	foreach boolean [list auto_save_p confirmation_p signature_p \
                              forward_p delete_move_index_p] {
	    if { ![string equal [set $boolean] "t"] && 
                 ![string equal [set $boolean] "f"] } {
		ad_complain "You have entered an improper boolean value 
                             for $boolean: [set $boolean] (\"t\" or \"f\" 
                             only please)"
	    }
	}
    }
    messages_per_page_in_range {
	if { ![empty_string_p $messages_per_page] &&
	( $messages_per_page > 999 || $messages_per_page < 10 ) } {
	    ad_complain "Please enter a number between 10 and 999 for
                         the number of messages per page."
	}
	 
    }
}

set user_id [ad_verify_and_get_user_id]
set forward_address [string tolower $forward_address]


# Let's check if they have updated the foward_address field.
# If they have, we must update their qmail alias file.

set old_forward [wm_get_preference $user_id forward_address]
set old_forward_p [wm_get_preference $user_id forward_p]
set alias_filename ""

if { (![string equal $old_forward $forward_address] && [string equal $forward_p t])
|| ![string equal $old_forward_p $forward_p] } {

    set alias_string [ad_decode [empty_string_p $forward_address] 1 [ad_parameter -package_id [wm_get_webmail_id] QueueDirectory] $forward_address]

    set alias_string [ad_decode [string equal $forward_p "t"] 1 $alias_string [ad_parameter -package_id [wm_get_webmail_id] QueueDirectory]]

    db_1row wm_domain_and_user_name {
	SELECT m.domain, email_user_name
	FROM wm_email_user_map m, wm_domains d
	WHERE d.short_name = m.domain 
	AND m.user_id = :user_id
    }
    set alias_filename [wm_get_alias_filename $domain $email_user_name]
}

# use a transaction so we don't have inconsistent db/alias states
db_transaction {
    db_dml update_preferences {
	UPDATE wm_preferences 
	SET signature_p = :signature_p, 
	  messages_per_page = :messages_per_page,
	  forward_address = :forward_address,
	  forward_p = :forward_p,
	  auto_save_p = :auto_save_p,
	  confirmation_p = :confirmation_p,
	  reply_to = :reply_to,
	  from_name = :from_name,
	  delete_move_index_p = :delete_move_index_p,
	  client_time_zone = :timezone
	WHERE user_id = :user_id
    }
	
    if { ![empty_string_p $alias_filename] } {
	ns_log Notice "Updating alias: $alias_filename"
	set alias_fp [open $alias_filename w 0644]
	puts $alias_fp $alias_string
	close $alias_fp
    }
} on_error {
    wm_return_error "We encountered the following error when attempting to update your preferences:

$errmsg
"
}
ad_set_client_property -persistent f "webmail" "client_tz_offset" ""

ad_returnredirect $return_url


