# /webmail/www/admin/problems.tcl

ad_page_contract {
    Deal with common webmail problems.

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-04-03
    @cvs-id $Id$
} {}
    

## Parse Errors
set parse_errors ""

db_foreach errors {
    select filename, error_message, to_char(first_parse_attempt, 'YYYY-MM-DD HH24:MI:SS') as pretty_parse_attempt_date
    from wm_parse_errors
    order by first_parse_attempt
} {
    append parse_errors "<li>$filename ($pretty_parse_attempt_date)
       <a href=\"parse-errors-delete?[export_url_vars filename]\">delete this error</a>
       <br>\n<pre>\n$error_message\n</pre>\n"
} if_no_rows {
    set parse_errors "<li>No parse errors\n"
}


## Broken Jobs

set broken_jobs ""

db_foreach broken_jobs {
    select job, what
    from user_jobs
    where broken = 'Y'
} {
    append broken_jobs "<li>$what <font size=-1>\[ <a href=\"job-restart?[export_url_vars job]\">Restart</a> \]</font>\n"
} if_no_rows {
    set broken_jobs "<li>No broken jobs\n"
}



doc_return 200 text/html "[ad_admin_header "Common WebMail Problems"]
<h2>Common Webmail Problems</h2>

 [ad_admin_context_bar [list "./" "WebMail Admin"] "Common Problems"]

<hr>

<h3>Parse Errors</h3>

<ul>
$parse_errors
</ul>

<p>

<a href=\"parse-errors-delete\">delete all errors</a>

<h3>Broken Jobs</h3>

If a dbms_job fails to execute enough times, it will be marked as \"broken\" 
and not run again.

<ul>
$broken_jobs
</ul>


[ad_admin_footer]
"
