# /webmail/www/create-view.tcl

ad_page_contract {
    creates or edits a view
    
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-11-07
    @cvs-id $Id$
} {
    view_name:notnull
    and_p:notnull
    comp_object:array,notnull
    comp_type:array,notnull
    comp_string:array

    age_type:notnull
    age_string:integer
    
    status:notnull
    action:notnull
    { mailboxes:multiple,integer "" }
    { edit_filter_id:integer 0 }
    { return_url manage-views }
} -validate {
    view_name_valid -requires { view_name:notnull } {
        if { [string length $view_name] > 50 } {
	    ad_complain { The name you specified was too long (50 characters max) }
	}
    }
}

set mailboxes [ad_decode [empty_string_p $mailboxes] 1 0 [join $mailboxes ,]]

set filter_list [list]
for { set i 1 } { $i < 4 } { incr i } {
    set this_object $comp_object($i) 
    if { [string equal $this_object off] } {
	continue
    }
    set this_type $comp_type($i)
    set this_string $comp_string($i)
    lappend filter_list [list $this_object $this_type $this_string]
}
if { ![empty_string_p $age_type] && ![string equal $age_type off] } {
    lappend filter_list [list date $age_type $age_string]
}
lappend filter_list [list read matches $status]

set user_id [ad_conn user_id]
set edit_filter_p [db_string filter_view_exists {
    SELECT 1 FROM wm_filter_views
    WHERE filter_id = :edit_filter_id
    AND user_id = :user_id } -default "0"]

db_transaction {
    if { $edit_filter_p } {
	db_dml view_update {
	    UPDATE wm_filter_views
	    set mailbox_ids=:mailboxes, 
	    name=:view_name, and_p=:and_p
	    WHERE filter_id=:edit_filter_id }
	db_dml view_delete_constraints {
	    DELETE FROM wm_filter_constraints
	    WHERE filter_view=:edit_filter_id }
	set filter_view $edit_filter_id
    } else {
	set filter_view [db_nextval wm_global_sequence]
	db_dml view_insert {
	    INSERT INTO wm_filter_views
	    (filter_id, user_id, mailbox_ids, name, and_p)
	    VALUES 
	    (:filter_view, :user_id, :mailboxes, 
	    :view_name, :and_p) }
    }
    foreach filter $filter_list {
	set this_object [lindex $filter 0] 
	set this_type [lindex $filter 1]
	set this_string [lindex $filter 2] 
	db_dml view_filter_insert1 {
	    call webmail.filter_add_constraint(:filter_view,:this_object,:this_type,:this_string)
	}
    }
} on_error {
    wm_return_error "
We had an error inserting this view:
$errmsg
"
    ad_script_abort
}

set view_id $filter_view
ad_returnredirect "$return_url?[export_url_vars view_id edit_filter_id]"

