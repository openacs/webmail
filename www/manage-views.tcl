# /webmail/www/manage-views.tcl

ad_page_contract {
    Displays a page for editing and creating views.
    
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-11-07
    @cvs-id $Id$
} {
    { edit_filter_id:integer 0 }
} -properties {
    context:onevalue
    edit_filter_id:onevalue
    filter_name:onevalue
    filters:multirow
}

template::multirow create filters filter_id name

set user_id [ad_maybe_redirect_for_registration]

set filter_name ""

# set up links to edit the other filters
set filter_query {
    SELECT name, filter_id FROM wm_filter_views
    WHERE user_id=:user_id
}
db_foreach filter_query $filter_query {
    if { $filter_id == $edit_filter_id } {
	set filter_name $name
    }
    template::multirow append filters $filter_id $name
}


set context "[ad_context_bar_ws [list "index" "Webmail"] "Manage Views"]" 

ad_return_template
