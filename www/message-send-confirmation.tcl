# /webmail/www/message-send-confirmation.tcl

ad_page_contract {
    Give a confirmation that the message was sent.

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-27
    @cvs-id $Id$
} {
    return_url:notnull
} -properties {
    context:onevalue
    return_url:onevalue
}
set context "[ad_context_bar_ws [list "index" "Webmail"] "Message Confirmation"]"
ad_return_template


