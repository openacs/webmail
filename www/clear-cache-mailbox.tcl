# /webmail/www/clear-cache-mailbox.tcl

ad_page_contract {
    Clears cached message_ids and redirects
    
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-12-21
    @cvs-id $Id$
} {
    orderby:optional
    mailbox_id:optional
    page_num:optional
}

ad_set_client_property -persistent f "webmail" "current_messages" ""
ad_returnredirect "index?[export_url_vars orderby mailbox_id page_num]"




