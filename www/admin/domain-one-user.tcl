# /webmail/www/admin/domain-one-user.tcl

ad_page_contract {
    Displays account info for one user

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-12-22
    @cvs-id $Id$
} {
    user_id:notnull
    short_name:notnull
}

set full_domain_name [db_string full_domain_name "select full_domain_name
from wm_domains
where short_name = :short_name"]

set account_name [db_string account_name "SELECT email_user_name FROM
wm_email_user_map 
WHERE user_id=:user_id" -default ""]

if { [empty_string_p $account_name] } {
    ad_return_complaint 1 "You have specified an invalid user."
    return
}

db_1row wm_user_account_info {
    SELECT person.name(:user_id) as name, count(1) as num_msgs, 
    nvl(sum(msg_size),0) as total_size
    FROM wm_messages wm, wm_mailboxes mb 
    WHERE wm.mailbox_id=mb.mailbox_id
    AND mb.user_id=:user_id
}


doc_return 200 text/html "[ad_admin_header "One Domain"]
<h2>$full_domain_name</h2>

[ad_admin_context_bar [list "./" "WebMail Admin"] "domain-one?[export_url_vars short_name]" "One Domain"]

<hr>
<blockquote>
<h3>$name</h3>
<ul>
<li>Account: $account_name@$full_domain_name
<li>Total number of messages: [util_commify_number $num_msgs]
<li>Total account size: [util_commify_number $total_size] Kb
</ul>
<a href=\"delete-user?[export_url_vars short_name user_id]\">Delete this account</a>
</blockquote>
[ad_admin_footer]
"













