# /webmail/www/folder-move-to.tcl

ad_page_contract {
    Set the current folder to mailbox_id and return to index.
    
    @param mailbox_id Usually, this is the ID of the mailbox. If set to "@NEW", we redirect
    to create a new mailbox

    @author Jin Choi (jsc@arsdigita.com)
    @creation-date 2000-02-23
    @cvs-id $Id$
} {
    mailbox_id
    { return_url "index" }
}

if { $mailbox_id == "@NEW" } {
    # Create new mailbox.
    ad_returnredirect "folder-create?target=[ad_urlencode $return_url]"
    return
}

# Have to explicitly validate this integer because it was not validated in
# ad_page_contract
validate_integer mailbox_id $mailbox_id

set cached_mailbox_id [ad_get_client_property "webmail" "mailbox_id"]

if { $cached_mailbox_id != $mailbox_id } {
    ad_set_client_property -persistent f "webmail" "mailbox_id" $mailbox_id
}

ad_returnredirect $return_url
