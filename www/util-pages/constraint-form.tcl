# /webmail/www/util-pages/constraint-form.tcl
# @author Erik Bielefeldt (erik@arsdigita.com)
# @creation-date 2001-01-02
# @cvs-id $Id$
#
# Parameters: 
#   edit_filter_id 
#     Specify 0 for edit_filter_id to have an empty form or -1 
#     to read it from the client_properties
#   { num_per_line 2 } 
#     Number of mailbox checkboxes you want on each line
#   { no_text f }
#     Pass no_text="t" to have a form w/o the text explanations
#
# Properties:
#   mailboxes:multirow
#   constr_selected:multirow
#   edit_filter_id:onevalue
#

template::multirow create mailboxes mailbox_id name checked newrow
template::multirow create constr_selected comp_object comp_type comp_string


set user_id [ad_conn user_id]

if { ![exists_and_not_null num_per_line] } {
    set num_per_line 2
}

if { ![exists_and_not_null no_text] } {
    set no_text f
}

set edit_filter_p 1
if { $edit_filter_id == -1 } {
    set mailbox_ids [ad_get_client_property "webmail" "filter_mailboxes"]
    set filter_list [ad_get_client_property "webmail" "filter_constraints"]
    set and_p [ad_get_client_property "webmail" "filter_and_p"]
    set filter_name ""
    set edit_filter_p 0
} elseif { $edit_filter_id == 0 } {
    set edit_filter_p 0
    set mailbox_ids 0
    set and_p t
    set filter_name ""
    set filter_list [list]
} elseif { ![db_0or1row one_filter_view {
    SELECT mailbox_ids, name as filter_name, and_p 
    FROM wm_filter_views WHERE 
    filter_id = :edit_filter_id AND user_id = :user_id
}] } {
    set edit_filter_p 0
    set mailbox_ids 0
    set and_p t
    set filter_name ""
    set filter_list [list]
}

# set up mailboxes template variable
set count 0
set mailbox_ids [split $mailbox_ids ,]
db_foreach mailbox_query {
    SELECT mailbox_id, name FROM wm_mailboxes
    WHERE user_id = :user_id
    ORDER BY mailbox_id
} {
    template::multirow append mailboxes $mailbox_id [wm_mailbox_name_for_display $name] [ad_decode [lsearch $mailbox_ids $mailbox_id] -1 "" checked] [ad_decode [expr $count % $num_per_line] 0 t f]
    incr count
}

# set up constraint variables
if { $edit_filter_p } {
    set filter_list [db_list_of_lists filter_constraints_list {
	SELECT comp_object, comp_type, comp_string 
	FROM wm_filter_constraints 
	WHERE filter_view = :edit_filter_id 
    }]
} 
    
set read_string "either"
set age_type "off"
set age_string ""
set i 1

foreach filter $filter_list {
    util_unlist $filter comp_object comp_type comp_string
    if { [string equal $comp_object date] } {
	set age_type $comp_type 
	set age_string $comp_string
    } elseif { [string equal $comp_object read] } {
	set read_string $comp_string
    } else {
	template::multirow append constr_selected $comp_object $comp_type $comp_string
	incr i
    }
}
# fill in empty constraints w/ defaults
for {} { $i <= 3 } { incr i } {
    template::multirow append constr_selected "off" "contains" ""
}

ad_return_template
return
