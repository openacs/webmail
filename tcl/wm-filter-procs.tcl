# /webmail/tcl/wm-filter-procs.tcl
ad_library {

    Includes procs for dealing with views in the Webmail system.
    <p>
    This is free software distributed under the terms of the GNU Public
    License.  Full text of the license is available from the GNU Project:
    http://www.fsf.org/copyleft/gpl.html

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2001-01-11
    @cvs-id $Id$
}


ad_proc wm_likefy { string } { 
    Double quotes quotes and escapes % and \ with \ for an Oracle "like" clause
} {
    set string [DoubleApos $string]
    regsub {\\} $string {\\\\} string
    regsub {%} $string {\\%} string
    return $string
}


ad_proc wm_build_view_sql { user_id view_id } {
    Builds the inner part of the complex index-view query
    for the specified view.
    If you pass view_id as -1, it will attempt to get the view from 
    the client's browser properties (used for the "Custom View")
    @return The sql needed for the view query
} {
    if { $view_id == -1 } {
	set mailbox_ids [ad_get_client_property "webmail" "filter_mailboxes"]
	set constraint_list [ad_get_client_property "webmail" "filter_constraints"]
	set and_p [ad_get_client_property "webmail" "filter_and_p"]
	if { [empty_string_p $mailbox_ids] || [empty_string_p $constraint_list] || 
	[empty_string_p $and_p] } {
	    ad_returnredirect index-search
            ad_script_abort
	}
    } elseif { ![db_0or1row view_query {
	SELECT mailbox_ids, and_p
	FROM wm_filter_views
	WHERE filter_id=:view_id
	AND user_id=:user_id}] } {
	    return ""
    }
    # comb is what we will use to combine the sql constraints (AND or OR)
    set comb [ad_decode $and_p t AND OR]
    if { $view_id != -1 } {
	set constraint_list [db_list_of_lists constraint_list {
	    SELECT comp_object, comp_type, comp_string
	    FROM wm_filter_constraints 
	    WHERE filter_view=:view_id}]
    }
    # tabls_string includes the sql for selecting which tables we need
    set table_string " FROM wm_messages m "

    # where string includes the first part of the where clause
    # which is not affected by the value of "and_p" or "comb"
    # it includes things like which mailboxes to select
    # and whether the search is limited to unread messages, etc.
    # if mailbox_ids is 0, we search all mailboxes
    if { [string equal $mailbox_ids 0] } {
	set where_string "WHERE mailbox_id in ([join [db_list users_folders {
	    SELECT mailbox_id FROM wm_mailboxes WHERE user_id=:user_id } ] ","]) "
    } else {
	set where_string "WHERE mailbox_id in ($mailbox_ids) "
    }

    # where_list is a list of sql conditions which will be joined 
    # by the variable comb
    # where_list will contain comparisons of search strings to 
    # different fields (headers, body, etc.)
    set where_list [list]

    # "i" is a counter which we append to the name of wm_headers
    # to distinguish between seperate references to it
    # (i.e. if we join w/ wm_headers twice, we'll refer to the first
    # as "h1" and the second as "h2"
    set i 1
    set ctx_key 1

    # Here we loop through for each constraint, 
    # building and adding to the appropriate strings.
    foreach constraint $constraint_list {
	util_unlist $constraint comp_object comp_type comp_string
	set comp_string [string tolower $comp_string]
	# First we switch the comp_object to build an appropriate comp_string
	# The comp_string will be what we compare the column we are searching to,
	# so it will look like " = 'blah'" or " like '%blah%'" etc.
	switch $comp_object {
	    read {
		switch $comp_string {
		    # this should be ANDed regardless of and_p
		    read { append where_string " AND m.seen_p = 't' " }
		    unread { append where_string " AND m.seen_p = 'f' " }
		}
	    }
	    date {
		set comp_string [wm_filter_date_comp_helper $comp_string $comp_type]
	    }
	    body {
		set comp_string $comp_string
	    }
	    default {
		set comp_string [wm_filter_default_comp_helper $comp_string $comp_type]
	    }
	}
	# Here we switch comp_object again in order to build the actual where clause
	switch $comp_object {
	    date {
		if { [string equal $comp_type matches] 
		|| [string equal $comp_type no_match] } {
		    lappend where_list "trunc(m.${comp_object}_value) $comp_string"
		} else {
		    lappend where_list "m.${comp_object}_value $comp_string"
		}
	    }
	    subject - to - from - cc {
		append table_string " , wm_headers h$i "
		append where_string " AND h$i.msg_id = m.msg_id AND lower(h$i.name) = '$comp_object' "
		lappend where_list "lower(h$i.value) $comp_string"
	    }
	    header {
		lappend where_list "(EXISTS (SELECT 1 FROM wm_headers wh
		                     WHERE wh.msg_id = m.msg_id 
		                     AND lower(value) $comp_string))"
	    }
	    body { 
		lappend where_list [wm_filter_body_comp_helper $comp_string $comp_type $ctx_key]
		incr ctx_key
	    }
	}
	incr i
    }
    return "$table_string $where_string [ad_decode [llength $where_list] 0 "" "AND ([join $where_list " $comb "])"]"
}


ad_proc -private wm_filter_date_comp_helper { comp_string comp_type } {
    @return An appropriate value for the comp_string
} {
    switch $comp_type {
	matches { set comp_string " = trunc(sysdate - $comp_string) " }
	no_match { set comp_string " != trunc(sysdate - $comp_string) " }
	less_than { set comp_string " > (sysdate - $comp_string) " }
	more_than { set comp_string " < (sysdate - $comp_string) " }
    }
    return $comp_string
}


ad_proc -private wm_filter_body_comp_helper { comp_string comp_type ctx_key } {
    Note: you may add an appropriate clause to this proc for 
    searching attachments too, provided you have indexed that table
    @return An appropriate value for the comp_string
} {
    return "(contains(m.body, '[db_quote $comp_string]', $ctx_key) [ad_decode $comp_type no_contain " = 0" " > 0"])"
}


ad_proc -private wm_filter_default_comp_helper { comp_string comp_type } {
    @return An appropriate value for the comp_string
} {
    switch $comp_type {
	matches { 
	    if { [empty_string_p $comp_string] } {
		set comp_string " is null "
	    } else {
		set comp_string " = '$comp_string' " 
	    }
	}
	no_match { 
	    if { [empty_string_p $comp_string] } {
		set comp_string " is not null "
	    } else {
		set comp_string " != '$comp_string' " 
	    }
	}
	contains { set comp_string " like '%[wm_likefy $comp_string]%' escape '\\' " }
	no_contain { set comp_string " not like '%[wm_likefy $comp_string]%' escape '\\' " }
	starts_with { set comp_string " like '[wm_likefy $comp_string]%' escape '\\' " }
	ends_with { set comp_string " like '%[wm_likefy $comp_string]' escape '\\' " }
    }   
    return $comp_string
}


