# /webmail/www/admin/domain-delete-2.tcl

ad_page_contract {
    Delete a domain

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-11-14
    @cvs-id $Id$
} {
    short_name:notnull
    action:notnull
}


if { $action == "Delete" } {
    # even though webmail.delete_domain deletes the users in the domain,
    # we call wm_delete_user because that will remove the qmail files too.
    db_foreach users_in_domain { 
	SELECT user_id FROM wm_email_user_map 
	WHERE domain=:short_name } {
	ns_log Notice "deleting: $user_id"
	wm_delete_user $user_id
    }
    db_dml wm_delete_domain "begin webmail.delete_domain(:short_name); end;"
    ad_returnredirect "index"
    ad_script_abort
} else {
    ad_returnredirect "domain-one?[export_url_vars short_name]"
    ad_script_abort
}


