# /webmail/www/admin/admin-choose-2.tcl

ad_page_contract {
    Set a new admin account.
    
    @author Erik Bielefeldt (erik@arsdigita.com)
    @creation-date 2001-01-20
    @cvs-id $Id$
} {
    short_name:notnull
    user_id:notnull
}

db_transaction {
    db_dml update_admin {
	UPDATE wm_domains 
	SET admin_user_name=
	  (SELECT email_user_name FROM wm_email_user_map
	    WHERE user_id = :user_id AND domain = :short_name)
	WHERE short_name = :short_name
    }
    db_dml insert_system_mailbox {
	INSERT INTO wm_mailboxes 
	(mailbox_id, name, user_id)
	SELECT wm_global_sequence.nextval, 'SYSTEM', :user_id
	FROM dual WHERE NOT EXISTS 
	      (SELECT 1 FROM wm_mailboxes 
	      WHERE name = 'SYSTEM' AND user_id = :user_id)
    }
} on_error {
    doc_return 200 text/html "$errmsg"
}

ad_returnredirect "domain-one?[export_url_vars short_name]"
