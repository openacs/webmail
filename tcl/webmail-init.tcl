# /webmail/tcl/webmail-init.tcl

ad_library {
    Initialization for webmail.
    <p>
    This is free software distributed under the terms of the GNU Public
    License.  Full text of the license is available from the GNU Project:
    http://www.fsf.org/copyleft/gpl.html

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2001-02-08
    @cvs-id $Id$

}

ad_proc -public wm_get_webmail_id {} {
    @return The object id of webmail if it exists, 0 otherwise.
} {
    return [apm_package_id_from_key webmail]
}


############# SCHEDULE QUEUE PROCESSING ####################

ad_proc wm_process_email { directory } {
    Looks in the queue directory and processes all the emails there.
    This could be scheduled with Oracle's dms_job package, 
    but Oracle 8.1.5 doesn't process scheduled jobs correctly, and 8.1.6
    loses the message bodies.  Scheduling w/ AolServer is the safest 
    bet for now.
} {
    db_dml wm_process_queue "begin webmail.process_queue('$directory'); end;"
}

# Schedule wm_process_email for every minute
# We don't have to worry about concurrency issues because
# the interval argument to ns_schedule proc is not really 
# the interval between start times but the interval between 
# the time the first proc finishes and the next one begins.
# I.e. ns_schedule proc will never run this procedure 
# twice at the same time.
ad_schedule_proc -thread t 60 wm_process_email [ad_parameter -package_id [wm_get_webmail_id] QueueDirectory]new/


