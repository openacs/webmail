# /webmail/www/admin/domain-one.tcl

ad_page_contract {
    Display users for one mail domain.

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    short_name:notnull
}

set full_domain_name [db_string full_domain_name "select full_domain_name
from wm_domains
where short_name = :short_name"]

set user_count [db_string wm_domain_user_count {
    SELECT count(1) FROM wm_email_user_map
    WHERE domain = :short_name }]

db_0or1row wm_domain_admin {
    SELECT eum.user_id, person.name(eum.user_id) as admin_name, 
      eum.email_user_name 
    FROM wm_email_user_map eum, wm_domains d
    WHERE d.admin_user_name = eum.email_user_name
}

if { ![exists_and_not_null user_id] } {
    set admin_comment "<b>This domain does not have an administrator
    and admin mailbox associated with it.  Please <a href=\"admin-choose?[export_url_vars short_name full_domain_name]\">choose</a>
    one now.</b>
    <p>"
} else {
    set admin_comment "
    Domain admin: <b>$admin_name &lt;$email_user_name@$full_domain_name></b>
    <a href=\"admin-choose?[export_url_vars short_name full_domain_name]\">Choose a new admin</a><br>"
}

set target "domain-one-user"
doc_return 200 text/html "[ad_admin_header "One Domain"]
<h2>$full_domain_name</h2>

[ad_admin_context_bar [list "./" "WebMail Admin"] "One Domain"]

<hr>
<blockquote>
$admin_comment
Domain name: <b>$full_domain_name</b><br>
Domain short name: <b>$short_name</b><br>
Accounts in this domain: <b>[util_commify_number $user_count]</b><br>
<p>
<form action=\"search-results\">
[export_form_vars short_name target]
Search for account in this domain:&nbsp;
<input type=text name=search_string size=15>
</form>

<p>
<a href=\"domain-add-user?[export_url_vars short_name]\">Add a user</a><br>

<a href=\"domain-delete?[export_url_vars short_name]\">Delete this domain</a>
<br><br>
</blockquote>
[ad_admin_footer]
"











