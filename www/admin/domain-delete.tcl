# /webmail/www/admin/domain-delete.tcl

ad_page_contract {
    Delete a domain

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-11-14
    @cvs-id $Id$
} {
    short_name:notnull
}

set full_domain_name [db_string full_domain_name "select full_domain_name
from wm_domains
where short_name = :short_name"]

doc_return 200 text/html "[ad_admin_header "Delete Domain"]
<h2>Delete Domain</h2>

[ad_admin_context_bar [list "./" "WebMail Admin"] "Delete Domain"]

<hr>
<br>
Really delete the domain <b>$full_domain_name</b>?</br>
This will delete all associated email accounts.

<form action=\"domain-delete-2\">
[export_form_vars short_name]
<input type=submit name=action value=Delete>&nbsp;&nbsp;
<input type=submit name=action value=Cancel>
</form>

"
