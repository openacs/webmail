# /webmail/www/clear-cache-view.tcl

ad_page_contract {
    Clears cached message_ids and redirects to the index-view.
     
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-12-21
    @cvs-id $Id$
} {
    orderby:optional
    view_id:optional
    page_num:optional
    customize:optional
}

ad_set_client_property -persistent f "webmail" "current_messages" ""
ad_returnredirect "index-view?[export_url_vars view_id page_num orderby customize]"




