# /webmail/www/admin/job-restart.tcl

ad_page_contract {
    Restart a broken job.

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-04-03
    @cvs-id $Id$
} {
    job:integer
}

set db [ns_db gethandle]

ns_db dml $db "begin dbms_job.broken($job, FALSE, sysdate); end;"

ad_returnredirect "problems.tcl"

