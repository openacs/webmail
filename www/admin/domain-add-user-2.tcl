# /webmail/www/admin/domain-add-user-2.tcl

ad_page_contract {
    Assign email address to ACS user.

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    username:notnull
    short_name:notnull
}

set full_domain_name [db_string full_domain_name "select full_domain_name
from wm_domains
where short_name = :short_name"]



doc_return 200 text/html "[ad_admin_header "Specify Recipient"]
<h2>$full_domain_name</h2>

<hr>

Specify recipient who will receive email sent to $username@$full_domain_name:

<form action=\"/acs-admin/users/search\">
<input type=hidden name=target value=\"[wm_get_mount_point]admin/domain-add-user-3\">
<input type=hidden name=passthrough value=\"username short_name\">
[export_form_vars username short_name]

Email: <input type=text name=email size=50 value=\"[philg_quote_double_quotes $username]\">
<p>
or
<p>
Last Name: <input type=text name=last_name size=50>

<center>
<input type=submit value=\"Find User\">
</center>

[ad_admin_footer]
"