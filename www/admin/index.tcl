# /webmail/www/admin/index.tcl

ad_page_contract {
    Display list of mail domains we handle on this server.

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {}

set results ""

with_catch errmsg {
    db_foreach domains {
	select short_name, full_domain_name
	from wm_domains
	order by short_name
    } {
	append results "<li><a href=\"domain-one?[export_url_vars short_name]\">$full_domain_name</a>\n"
    } if_no_rows {
	set results "<li>No domains currently handled.\n"
    }
} {
    set results "<li><b>Error retrieveing data from database--please consult the installation guide.</b>"
}

doc_return 200 text/html "[ad_admin_header "WebMail Administration"]
<h2>WebMail Administration</h2>

[ad_admin_context_bar "WebMail Admin"]

<hr>
<i>If this is the first time you are using Webmail, please review the 
<a href=\"../doc/acs-admin-guide.html\">Install Document</a> to make
sure you have followed all the required steps to configure Webmail properly.</i>

<p>

Domains we handle email for:

<ul>
$results
<p>
<a href=\"domain-add\">Add a domain</a>
</ul>

<p>

<a href=\"problems\">administer common errors</a>

[ad_admin_footer]
"
