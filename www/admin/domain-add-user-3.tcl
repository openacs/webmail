# /webmail/www/admin/domain-add-user-3.tcl

ad_page_contract {
    Add the user.

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    username:notnull
    short_name:notnull
    user_id_from_search:integer,notnull
}

wm_add_user $user_id_from_search $username $short_name

ad_returnredirect "domain-one?[export_url_vars short_name]"
