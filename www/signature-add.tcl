# /webmail/www/signature-add.tcl

ad_page_contract {
    Edit signature

    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2000-09-26
    @cvs-id $Id$
} {
    { update "0" }
} -properties {
    update:onevalue
    html_check:onevalue
    current_signature:onevalue
}

set user_id [ad_conn user_id]

set current_signature [wm_get_preference $user_id signature]

set html_p [wm_get_preference $user_id signature_html_p]

set html_check [ad_decode [string equal $html_p "t"] 1 "checked" ""]








