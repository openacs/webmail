# /webmail/www/admin/parse-errors-delete.tcl

ad_page_contract {
    Delete one or all rows in wm_parse_errors.
    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-04-03
    @cvs-id $Id$
} {
    { filename "" }
}

if { [empty_string_p $filename] } {
    db_dml parse_errors_delete {
	DELETE FROM wm_parse_errors
    } 
} else {
    db_dml parse_error_delete {
	DELETE FROM wm_parse_errors 
	WHERE filename = :filename
    } 
}

ad_returnredirect "problems"
