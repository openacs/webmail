# /webmail/www/admin/delete-user-2.tcl

ad_page_contract {
    Delete a webmail user

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-11-14
    @cvs-id $Id$
} {
    user_id:integer,notnull
    action:notnull
    short_name:notnull
}


if { $action == "Delete" } {
    set errmsg ""
    set errmsg [wm_delete_user $user_id]
    if { ![empty_string_p $errmsg] } {
	set result "[ad_admin_header "Delete User"]
	<h2>Delete User</h2>
	
	[ad_admin_context_bar [list "index.tcl" "WebMail Admin"] "One Domain"]
	
	<hr><br>
	<b>We received the following error:</b>
	<pre>
	$errmsg
        </pre>"

	if { [regexp {unlink(.*)failed} $errmsg] } {
	    append result "
	    We have deleted the user from the database; please verify that 
	    the specified alias file no longer exists."
	} 
	doc_return 200 text/html $result
    } else {
	ad_returnredirect "domain-one?[export_url_vars short_name]"
        ad_script_abort
    }
} else {
    ad_returnredirect "domain-one-user?[export_url_vars user_id short_name]"
    ad_script_abort
}

