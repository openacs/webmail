# /webmail/www/signature-add-2.tcl

ad_page_contract {
    Edit signature

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-26
    @cvs-id $Id$
} {
    signature:notnull,allhtml
    {html ""}
    action:notnull
} -properties {
    update:onevalue
    action:onevalue
}

set user_id [ad_verify_and_get_user_id]

set signature [ad_decode [string equal $action "Delete"] 1 "" $signature]
set html_p [ad_decode [empty_string_p $html] 1 "f" "t"]

db_dml update_signature "UPDATE wm_preferences
                         SET signature=:signature,
                         signature_html_p=:html_p
                         WHERE user_id=:user_id" 

ad_return_template


