# /webmail/www/admin/delete-user.tcl

ad_page_contract {
    Confrim delete of a webmail user

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-11-14
    @cvs-id $Id$
} {
    user_id:integer,notnull
    short_name:notnull
}

set full_name [db_string full_name "
    select person.name(:user_id) from dual"]

set email [db_string wm_email "select email_user_name 
    || '@' || full_domain_name from wm_email_user_map eum, 
    wm_domains wd
    where eum.domain = wd.short_name
    and eum.user_id = :user_id"]

doc_return 200 text/html "[ad_admin_header "Delete User"]
<h2>Delete User</h2>

[ad_admin_context_bar [list "index.tcl" "WebMail Admin"] "One Domain"]

<hr>
<br>
Really delete the webmail account for  <b>$full_name: $email</b>?<br>
This will delete all associated mailboxes and messages.

<form action=\"delete-user-2.tcl\">
[export_form_vars short_name user_id]
<input type=submit name=action value=Delete>&nbsp;&nbsp;
<input type=submit name=action value=Cancel>
</form>

"
