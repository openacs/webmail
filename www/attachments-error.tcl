# /webmail/www/attachments-error.tcl

ad_page_contract {
    Display an error message for the attachments window.

    @param errmsg The error message to display
    @param outgoing_msg_id The message which we were trying to attach it to.
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2001-01-12
    @cvs-id $Id$
} {
    errmsg
    outgoing_msg_id:integer
}


ad_return_template
