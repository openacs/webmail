# /webmail/www/delete-view.tcl

ad_page_contract {
    deletes a view
    
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-11-07
    @cvs-id $Id$
} {
    edit_filter_id:integer,notnull
}

set user_id [ad_conn user_id]

db_dml delete {
    DELETE FROM wm_filter_views
    WHERE filter_id=:edit_filter_id
    AND user_id = :user_id
}

ad_returnredirect "manage-views"


