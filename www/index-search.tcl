# /webmail/www/index-search.tcl

ad_page_contract {
    Displays a form for a search
    
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-11-01
    @cvs-id $Id$
} {
} -properties {
    context:onevalue
}

set user_id [ad_maybe_redirect_for_registration]

set context "[ad_context_bar_ws [list "index?[export_url_vars mailbox_id]" "Webmail"] "Search"]" 
 
ad_return_template















