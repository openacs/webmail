# /webmail/www/admin/admin-choose.tcl

ad_page_contract {
    Present form for choosing a new admin for this domain.
    
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2001-01-20
    @cvs-id $Id$
} {
    short_name:notnull
    full_domain_name:notnull
}

set target "admin-choose-2"

doc_return 200 text/html "[ad_admin_header "Choose Admin"]
<h2>$full_domain_name</h2>

[ad_admin_context_bar [list "index.tcl" "WebMail Admin"] [list "domain-one.tcl?[export_url_vars short_name]" "One Domain"] "Choose Admin"]

<hr>
<br>
Search for a user (they must already have a Webmail account <b>in this domain</b>):

<form action=\"search-results\">
[export_form_vars short_name target]
Email address: <input type=text name=search_string size=10>
</form>

[ad_admin_footer]
"
