# /webmail/www/set-client-view.tcl

ad_page_contract {
  sets the view on the client's browser
  
  @author Erik Bielefeldt (erik@arsdigita.com)
  @creation-date 2000-11-15
  @cvs-id $Id$
} {
  and_p:notnull
  comp_object:array,notnull
  comp_type:array,notnull
  comp_string:array
  
  age_type
  age_string:integer
  
  action:notnull
  status:notnull
  { mailboxes:multiple,integer "" }
} -properties {
  form_vars:onevalue
  context:onevalue
} 

set mailboxes_list $mailboxes
set mailboxes [ad_decode [empty_string_p $mailboxes] 1 0 [join $mailboxes ,]]

if { [string equal $action "Search"] } {

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
    
    ## THIS IS A SEARCH -- CACHE THE SEARCH CRITERIA
    ad_set_client_property -persistent f "webmail" "filter_and_p" $and_p
    ad_set_client_property -persistent f "webmail" "filter_mailboxes" $mailboxes
    ad_set_client_property -persistent f "webmail" "filter_constraints" $filter_list  
    ad_returnredirect "clear-cache-view?customize=t&view_id=-1"
    ad_script_abort
}


## we need to pass all the form variables on 
set return_url "index-view"
set form_vars [export_form_vars and_p age_type age_string action status return_url]
foreach mailboxes $mailboxes_list {
    append form_vars [export_form_vars mailboxes]
}
for { set i 1 } { $i < 4 } { incr i } {
    set "comp_object.$i" $comp_object($i)
    set "comp_type.$i" $comp_type($i)
    set "comp_string.$i" $comp_string($i)
    append form_vars [export_form_vars "comp_object.$i" "comp_type.$i" "comp_string.$i"]
}

set context [ad_context_bar_ws [list "./" "WebMail"] "Save view"]

ad_return_template