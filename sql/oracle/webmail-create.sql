-- /webmail/sql/webmail-create.sql
-- @author Jin Choi (jsc@arsdigita.com)
-- @creation-date 2000-02-23
-- @cvs-id $Id$

-- Copyright (C) 2000 ArsDigita Corporation
-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html

-- Data model to support web based email system.

-- Database user must have javasyspriv permission granted to it:
-- Note that this is the default for an ACS 4.0 install
-- connect system
-- grant javasyspriv to <username>;

-- ctxsys must grant EXECUTE on ctx_ddl to this Oracle user:
-- connect ctxsys
-- grant execute on ctx_ddl to <username>;


create sequence wm_global_sequence;

create table wm_domains (
	short_name		varchar(100)
	  			constraint wm_domains_short_pk 
				primary key,
	full_domain_name	varchar(255)
				constraint wm_domains_full_nn
				not null
				constraint wm_domains_full_un
				unique,
	admin_user_name		varchar(100)
);

comment on table wm_domains is '
  Keeps track of domains webmail receives email for.
';

comment on column wm_domains.short_name is '
  short_name is a short unique identifier for the domain
';

comment on column wm_domains.full_domain_name is '
  fully qualified domain name
';


create table wm_email_user_map (
	user_id			integer 
				constraint wm_eum_user_id_fk 
				references users
				constraint wm_eum_user_id_pk 
				primary key, 
	email_user_name		varchar(100) 
				constraint wm_eum_user_name_nn
				not null,
	delivery_address	varchar(200) 
				constraint wm_eum_delivery_address_nn 
				not null,
	domain			varchar(100)
				constraint wm_eum_domain_nn
				not null
				constraint wm_eum_domain_fk 
				references wm_domains(short_name),
	constraint wm_eum_domain_user_un unique(domain, email_user_name)
);

comment on table wm_email_user_map is '
  Maps webmail accounts to ACS users.
';

comment on column wm_email_user_map.email_user_name is '
  The part of the email address preceding the "@"
  I.e. "bob" for the address "bob@nowhere.com"
';

comment on column wm_email_user_map.delivery_address is '
  The address that qmail will deliver to: 
  domain_short_name||''-''||email_user_name||''@''||full_domain_name
';


create table wm_mailboxes (
	mailbox_id	integer 
			constraint wm_mailboxes_id_pk 
			primary key,
	name		varchar(50) 
			constraint wm_mailboxes_name_nn
			not null,
	user_id		constraint wm_mailboxes_user_fk 
			references users(user_id),
	creation_date	date,
	constraint wm_mailboxes_user_name_un unique(user_id, name)
);

comment on table wm_mailboxes is '
  maps mailboxes (folders, in more common terminology) to ACS users
';


create table wm_messages (
        msg_id          integer 
			constraint wm_messages_id_pk primary key,
	mailbox_id	integer 
			constraint wm_messages_mailbox_nn
			not null
			constraint wm_messages_mailbox_fk
			references wm_mailboxes(mailbox_id),
        body            clob,
	mime_text	clob,
        message_id      varchar(500),
	msg_size	integer
			constraint wm_messages_size_nn not null,
	date_value	date default sysdate,
	subject_value	varchar(150),
	to_value	varchar(150),
	from_value 	varchar(150),
	seen_p		char(1) default 'f' 
			constraint wm_messages_seen_p_chk
			check(seen_p in ('t','f')),
	answered_p	char(1) default 'f' 
			constraint wm_messages_answered_p_chk
			check(answered_p in ('t','f')),
	flagged_p	char(1) default 'f' 
			constraint wm_messages_flagged_p_chk
			check(flagged_p in ('t','f')),
	deleted_p	char(1) default 'f' 
			constraint wm_messages_deleted_p_chk
			check(deleted_p in ('t','f')),
	draft_p		char(1) default 'f' 
			constraint wm_messages_draft_p_chk
			check(draft_p in ('t','f')),
	recent_p	char(1) default 't' 
			constraint wm_messages_recent_p_chk
			check(recent_p in ('t','f'))
);

comment on table wm_messages is '
  Main mail message table. Stores body of the email, along
  with a parsed text version with markers for attachments for MIME
  messages.  Also stores a short version of the four headers needed for the index view
  as well as flags on the status of the message--this increases the 
  performance of the index view, since we do not have to join 
  with any other tables to get the headers and flags.
';

comment on column wm_messages.mime_text is '
  Parsed version of body with flags for links to attachments
  Empty if entire message is of type text/plain
';

comment on column wm_messages.message_id is '
  RFC-822 Message-id field for linking to referenced messages
';

comment on column wm_messages.recent_p is '
  Currently unused, but may be used to track whether a message
  was new since the last visit by a user (to let the user know of
  "new" messages (not just unread)
';

-- makes the counting of read/unread per mailbox faster
create index wm_messages_by_mailbox_seen on wm_messages(mailbox_id,seen_p);

-- makes looking up message references faster
create index wm_messages_by_message_id on wm_messages(message_id);

-- makes the sort of the  most common index view (sorted by date_value) go faster
create index wm_messages_by_mailbox_date on wm_messages(mailbox_id, date_value);


create table wm_attachments (
	att_id		integer 
			constraint wm_att_att_id_pk primary key,
	msg_id		constraint wm_att_msg_id_nn not null 
			constraint wm_att_msg_id_fk
			references wm_messages(msg_id),
	filename	varchar(600) 
			constraint wm_att_filename_nn not null,
	content_type	varchar(100),
	data		blob
);

comment on table wm_attachments is '
  Stores attachments for MIME messages
';

comment on column wm_attachments.filename is '
  The filename associated with the attached file (i.e. the filename 
  on the senders filesystem, not on the servers filesystem)
';

-- Most common lookup is by msg_id and filename so we index it; also
-- it indexes the foreign key constraint to allow row-level locking 
-- on updates to wm_messages
create index wm_attachments_by_msg_id on wm_attachments(msg_id, filename);


create table wm_headers (
        msg_id          integer 
			constraint wm_headers_msg_id_nn not null 
			constraint wm_headers_msg_id_fk 
			references wm_messages(msg_id),
        name            varchar(100)
			constraint wm_headers_name_nn not null,
        value           varchar(4000),
        sort_order      integer 
			constraint wm_headers_sort_order_nn not null
);



comment on table wm_headers is '
  Stores a copy of all headers, including duplicates of the ones stored 
  in wm_messages (Jin Choi requested this duplication for ease of 
  integration with his IMAP server--originally, I didn't have it.)
  This will be the largest (in terms of rows) table in the system--
  about 8 times as many rows as the wm_messages table.
  This is one of the reasons why I removed the four most common headers 
  from this table.
';

comment on column wm_headers.name is '
  The name of the header (i.e. Cc, Bcc, Reply-To, etc.)
';

comment on column wm_headers.sort_order is '
  The original sort order of headers in the message.
';

-- Improve lookup of a single header for a message, as well as index 
-- the foreign key constraint
create index wm_headers_by_msg_id_name on wm_headers (msg_id, lower(name));


create table wm_parse_errors (
	filename		varchar(255) 
				constraint wm_parse_errors_file_pk 
				primary key,
	error_message		varchar(4000),
	first_parse_attempt	date default sysdate 
				constraint wm_parse_errors_nn not null
);

comment on table wm_parse_errors is '
  Records messages that we failed to parse.
';


create table wm_outgoing_messages (
	outgoing_msg_id		integer
				constraint wm_out_messages_id_pk 
				primary key,
	body			clob,
	creation_date		date default sysdate 
				constraint wm_out_messages_date_nn 
				not null,
	user_id			integer 
				constraint wm_out_messages_user_nn 
				not null 
				constraint wm_out_messages_user_fk
				references users(user_id)
);

comment on table wm_outgoing_messages is '
  Used for storing outgoing messages (messages being composed, 
  sent, or already sent).  
  This table is cleaned out periodically by a scheduled proc.
  Note that saved drafts are not kept in 
  this table, but are transfered to the main wm_messages table.
';

-- Index the foreign key constraint to allow row-level locking on updates
create index wm_outgoing_msg_by_user on wm_outgoing_messages(user_id);


create table wm_outgoing_headers (
	outgoing_msg_id		integer 
				constraint wm_out_headers_id_fk 
				references wm_outgoing_messages 
				on delete cascade,
	name			varchar(100) 
				constraint wm_out_headers_name_nn 
				not null,
	value			varchar(4000),
	sort_order		integer,
	constraint wm_outgoing_headers_pk
				primary key (outgoing_msg_id, name)
);

comment on table wm_outgoing_headers is '
  Stores headers associated with the messages in wm_outgoing_messages
';


create table wm_outgoing_message_parts (
	outgoing_msg_id		integer
				constraint wm_omp_id_fk 
				references wm_outgoing_messages 
				on delete cascade,
	data			blob,
	filename		varchar(600),				
	content_type		varchar(100), 
	sort_order		integer,
				constraint wm_omp_pk 
				primary key (outgoing_msg_id, sort_order)
);

comment on table wm_outgoing_message_parts is '
  Stores outgoing attachments.
';

create table wm_preferences (
	user_id			integer 
				constraint wm_pref_user_id_fk 
				references users(user_id)
				constraint wm_pref_user_id_pk
				primary key,
	signature		VARCHAR2(1000),
	signature_p		CHAR(1) default 'f' 
	                        constraint wm_pref_signature_p_chk
				check(signature_p in ('t','f')),
	signature_html_p	CHAR(1) default 'f' 
	                        constraint wm_pref_sig_html_chk
				check(signature_html_p in ('t','f')),
	messages_per_page	INTEGER default 50
				constraint wm_pref_msg_page_nn
				not null,
	forward_address		VARCHAR2(300),
	forward_p		CHAR(1) default 'f' 
	                        constraint wm_pref_forward_p_chk
				check(forward_p in ('t','f')),
	auto_save_p		CHAR(1) default 't' 
	                        constraint wm_pref_auto_save_p_chk
				check(auto_save_p in ('t','f')),
	confirmation_p		CHAR(1) default 't' 
	                        constraint wm_pref_confirm_p_chk
				check(confirmation_p in ('t','f')),
	reply_to		VARCHAR2(300),
	from_name		VARCHAR2(300),
	delete_move_index_p	CHAR(1) default 'f' 
	                        constraint wm_pref_del_move_p_chk
				check(delete_move_index_p in ('t','f')),
	client_time_zone	VARCHAR2(100) default 'GMT'
				constraint wm_pref_time_zone_nn
				not null
);

comment on table wm_preferences is '
  Stores user preferences
';

comment on column wm_preferences.signature_p is '
  Should the signature be added by default?
';

comment on column wm_preferences.signature_html_p is '
  Does the signature contain html tags?
';

comment on column wm_preferences.forward_p is '
  Should we forward mail to the "foward_address?"
';

comment on column wm_preferences.auto_save_p is '
  Should we automatically save a copy of outgoing messages?
';

comment on column wm_preferences.confirmation_p is '
  Should we display a confirmation page?
';

comment on column wm_preferences.delete_move_index_p is '
  "t" if we should move to the index view upon delete, 
  "f" if we should move to the next message upon delete.
';

comment on column wm_preferences.client_time_zone is '
  Hour offset from GMT of this user.
';


-- FILTER STUFF--USED IN VIEWS

create table wm_filter_views (
	filter_id	integer 
			constraint wm_filter_views_id_pk 
			primary key,
	user_id		integer 
			constraint wm_filter_views_user_nn
			not null 
			constraint wm_filter_views_user_fk 
			references users,
	mailbox_ids	varchar(1000) 
			constraint wm_filter_views_mailboxes_nn
			not null, 
	name		varchar(50) 
			constraint wm_filter_views_name_nn
			not null,
	and_p		char(1) default 't' 
			constraint wm_filter_views_and_p_chk 
			check (and_p in ('t','f'))
);

comment on table wm_filter_views is '
  Contains general view information
';

comment on column wm_filter_views.mailbox_ids is '
  Contains comma seperated list of mailboxes which the view applies to.
  0 if it applies to all the user''s mailboxes.
';

-- Makes it quick to look up a user's views, and also indexes the foreign key
create index wm_filter_views_by_user on wm_filter_views(user_id);


create table wm_filter_constraints (
	id		integer 
			constraint wm_constraints_pk
			primary key,
	comp_object	varchar(50) 
			constraint wm_constraints_object_nn 
			not null 
			constraint wm_constraints_object_chk
			check (comp_object in ('subject', 'to', 'date',
		 		'cc', 'from', 'body', 'read', 'header')),
	comp_type	varchar(50) 
			constraint wm_constraints_type_nn
			not null
			constraint wm_constraints_type_chk
			check (comp_type in ('contains','no_contain','matches',
	                        'no_match','starts_with','ends_with',
				'less_than','more_than')),
	comp_string	varchar(100),
	filter_view	integer 
			constraint wm_constraints_filter_nn
			not null
			constraint wm_constraints_filter_fk
			references wm_filter_views
			on delete cascade
);

comment on table wm_filter_constraints is '
  This table contains "comparisons" that are applied by the filters.
  The comp_object is the subject of the comparison,
  the comp_type is the type of comparison,
  and the comp_string is the string that comp_object is compared to.
  An example would be: "subject contains comp_string"
  The id is not really used right now, but is provided
  in case it will be needed in the future.
';

comment on column wm_filter_constraints.filter_view is '
  The filter that this constraint is associated with.
';

-- Index the foreign key
create index wm_filter_constraints_by_view on wm_filter_constraints(filter_view);


create or replace package webmail 
as

  procedure cleanup_outgoing_msgs;

  procedure process_queue (
      queuedir            in   varchar
  );

  procedure parse_message_from_file (
      filename            in   varchar
  );

  procedure reparse_message_from_db (
      msg_id		  in   number
  );

  function parse_date (
      datestr             in   varchar
  ) return date;

  procedure compose_message (
      outgoing_msg_id     in   number,
      forward_msg_id      in   number
  );

  function get_response_text (
      response_msg_id     in   number
  ) return varchar;

  procedure empty_mailbox (
      mailbox_id          in   integer
  );

  procedure delete_mailbox (
     mailbox_id           in    integer
  );

  procedure delete_user (
      v_user_id           in   integer
  );

  procedure delete_domain (
      v_short_name        in   varchar
  );

  function response_address (
      v_msg_id            in   integer
  ) return varchar;

  procedure filter_add_constraint (
      filter_id		  in   integer,
      comp_object         in   varchar,
      comp_type           in   varchar,
      comp_string         in   varchar
  );

end webmail;
/
show errors


create or replace package body webmail
as

  procedure cleanup_outgoing_msgs as
  begin
    delete from wm_outgoing_messages
      where creation_date < sysdate - 1;
  end;


  -- PL/SQL bindings for Java procedures
  procedure process_queue (queuedir IN VARCHAR) 
  as language java
  name 'com.arsdigita.mail.MessageParser.processQueue(java.lang.String)';


  -- useful for debugging
  procedure parse_message_from_file (filename IN VARCHAR)
  as language java
  name 'com.arsdigita.mail.MessageParser.parseMessageFromFile(java.lang.String)';

  -- useful for debugging
  procedure reparse_message_from_db (msg_id IN NUMBER)
  as language java
  name 'com.arsdigita.mail.MessageParser.reparseMessageFromDB(int)';

  function parse_date (datestr IN VARCHAR) return date
  as language java
  name 'com.arsdigita.mail.MessageParser.parseDate(java.lang.String)
  return java.sql.Timestamp';
    

  procedure compose_message (outgoing_msg_id IN NUMBER, forward_msg_id IN NUMBER)
  as language java
  name 'com.arsdigita.mail.MessageComposer.composeMimeMessage(int, int)';

  function get_response_text (response_msg_id IN NUMBER) return VARCHAR
  as language java
  name 'com.arsdigita.mail.MessageParser.getMsgResponseText(int)
  return java.lang.String';

  procedure empty_mailbox (mailbox_id IN INTEGER) 
  as 
  begin 
    -- delete 100 rows at a time, to avoid blowing out a rollback segment 
    loop 
      delete from wm_messages 
        where mailbox_id = empty_mailbox.mailbox_id 
          and rownum <= 100; 
      commit; 
      exit when sql%notfound; 
    end loop;     
  end; 

  procedure delete_mailbox (mailbox_id IN INTEGER)
  as
  begin
    webmail.empty_mailbox(mailbox_id);
    delete from wm_mailboxes where 
      wm_mailboxes.mailbox_id = delete_mailbox.mailbox_id;
  end; 

  procedure delete_user (v_user_id IN INTEGER)
  as
  cursor cur is 
	select mailbox_id from wm_mailboxes
	where user_id = v_user_id;
  begin
    for cur_val in cur
      loop
        delete_mailbox(cur_val.mailbox_id);
      end loop;
    delete from wm_preferences where user_id=v_user_id;
    delete from wm_filter_views where user_id=v_user_id;
    delete from wm_email_user_map where user_id=v_user_id;
  end;

  procedure delete_domain (v_short_name IN VARCHAR)
  as
  cursor cur is 
	select user_id from wm_email_user_map 
	where domain=v_short_name;
  begin
    for cur_val in cur
      loop
        delete_user(cur_val.user_id);
	commit;
      end loop;
    delete from wm_domains where short_name=v_short_name;
  end; 


  -- Utility function to determine email address for a response.
  function response_address (v_msg_id IN integer) return VARCHAR
  as
    from_address varchar(4000);
    reply_to_address varchar(4000);
  begin
    begin
      select value into reply_to_address
        from wm_headers
        where msg_id = v_msg_id
          and lower(name) = 'reply-to';
      return reply_to_address;
    exception
      when no_data_found then 
        select value into from_address
          from wm_headers
          where msg_id = v_msg_id
	  and lower(name) = 'from';
        return from_address;
    end;
  end;

  procedure filter_add_constraint (
      filter_id		  in   integer,
      comp_object         in   varchar,
      comp_type           in   varchar,
      comp_string         in   varchar
  )
  as
  begin
    insert into wm_filter_constraints
    (id, comp_object, comp_type, comp_string, filter_view)
    values
    (wm_global_sequence.nextval, comp_object, comp_type, 
    comp_string, filter_id);
  end;

end webmail;
/
show errors


-- Trigger to delete subsidiary rows when a message is deleted.
create or replace trigger wm_messages_delete_trigger
before delete on wm_messages
for each row
begin
   delete from wm_headers where msg_id = :old.msg_id;
   delete from wm_attachments where msg_id = :old.msg_id;
end;
/
show errors


-- Create a job to clean up orphaned outgoing messages every day.
declare
  job number;
begin
  dbms_job.submit(job, 'webmail.cleanup_outgoing_msgs;',
		  interval => 'sysdate + 1');
end;
/
show errors

-- interMedia index on body of message
create index wm_ctx_index on wm_messages (body) indextype is ctxsys.context;

-- INSO filtered interMedia index for attachments.
-- This may be used if you want to index attachments, but it might 
-- be more work for Oracle than it is worth:

--create index wm_att_ctx_index on wm_attachments (data)
--indextype is ctxsys.context parameters ('filter ctxsys.inso_filter');


-- Resync the interMedia index every hour.
-- I originally tried scheduling a 'ctx_ddl.sync_index(''wm_ctx_index'');'
-- call every hour, but had problems with the job breaking or not running.
-- I have not had any problems with the following method.

create or replace procedure wm_resync_indexes
as
begin
  execute immediate 'alter index wm_ctx_index rebuild online parameters(''sync'')';
--  execute immediate 'alter index wm_att_ctx_index rebuild online parameters(''sync'')';
end;
/
show errors
 
declare
  job number;
begin
  dbms_job.submit(job, 'wm_resync_indexes;', sysdate,'sysdate + 1/24');
end;
/
show errors
