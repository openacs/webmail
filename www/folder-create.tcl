# /webmail/www/folder-create.tcl

ad_page_contract {
    Present form to create a new folder.
    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    target
} -properties {
    context:onevalue
    target:onevalue
}


set context [ad_context_bar_ws [list "index.tcl" "WebMail"] "Create New Folder"]

ad_return_template
