# /webmail/webmail-error.tcl

ad_page_contract {
    Return an error.
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-15
    @cvs-id $Id$
} {
    errmsg:html
} -properties {
    errmsg:onevalue
}

set context [ad_context_bar_ws "WebMail"]
ad_return_template