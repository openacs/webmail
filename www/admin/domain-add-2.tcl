# /webmail/www/admin/domain-add-2.tcl

ad_page_contract {
    Create new domain.

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    full_name:notnull
    short_name:notnull
}

set short_name [string tolower $short_name]

if [db_0or1row check_if_domain_exists "select short_name as sn 
 from wm_domains where short_name = :short_name"] {
    ad_return_complaint 1 "Short name already exists. You either double-clicked or forgot to choose a unique short name" 
    ad_script_abort
} else {
    db_dml add_domain {
	insert into wm_domains (short_name, full_domain_name)
	values (:short_name, :full_name)
    }
}

ad_returnredirect {} 