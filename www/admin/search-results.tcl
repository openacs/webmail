# /webmail/www/admin/search-results.tcl

ad_page_contract {
    Display results of user search

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-12-22
    @cvs-id $Id$
} {
    short_name:notnull
    search_string:notnull
    target:notnull
}

set full_domain_name [db_string full_domain_name "select full_domain_name
from wm_domains
where short_name = :short_name"]

set search_phrase "%[string tolower $search_string]%"

set results "<ul>"
db_foreach wm_user_search {
    SELECT eum.email_user_name, eum.user_id, person.name(eum.user_id) as name
    FROM wm_email_user_map eum, cc_users cu
    WHERE eum.domain=:short_name
    AND cu.user_id=eum.user_id
    AND (eum.email_user_name LIKE :search_phrase
    OR cu.email LIKE :search_phrase
    OR cu.last_name LIKE :search_phrase
    OR cu.first_names LIKE :search_phrase)
} {
    append results "<li>$name &lt;<a href=\"$target?[export_url_vars user_id short_name]\">$email_user_name@$full_domain_name</a>>"
} if_no_rows {
    append results "<li>No users matching your search string were found."
}
append results "</ul>"

doc_return 200 text/html "[ad_admin_header "One Domain"]
<h2>$full_domain_name</h2>

[ad_admin_context_bar [list "./" "WebMail Admin"] "One Domain"]

<hr>
<blockquote>
$results
</blockquote>
[ad_admin_footer]
"



