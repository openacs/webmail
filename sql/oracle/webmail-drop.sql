-- webmail-drop.sql
-- @author Erik Bielefeldt (erik@arsdigita.com)
-- @creation-date 2000-02-14
-- @cvs-id $Id$

-- Sql to drop webmail package
-- You might get an error when trying to drop jobs...
-- If so, drop them by hand.

declare 
  v_job number;
begin
  select job into v_job from user_jobs where what='webmail.cleanup_outgoing_msgs;';
  dbms_job.remove(v_job);
  select job into v_job from user_jobs where what='wm_resync_indexes;';
  dbms_job.remove(v_job);
end;
/

drop sequence wm_global_sequence;

drop trigger wm_messages_delete_trigger;
drop procedure wm_resync_indexes;
drop package webmail;

drop index wm_messages_by_mailbox_seen;
drop index wm_messages_by_mailbox_date;
drop index wm_attachments_by_msg_id;
drop index wm_headers_by_msg_id_name;
drop index wm_outgoing_msg_by_user;
drop index wm_filter_views_by_user;
drop index wm_filter_constraints_by_view;
drop index wm_ctx_index;

drop table wm_parse_errors cascade constraints;
drop table wm_preferences cascade constraints;
drop table wm_filter_constraints cascade constraints;
drop table wm_filter_views cascade constraints;

drop table wm_outgoing_headers cascade constraints;
drop table wm_outgoing_message_parts cascade constraints;
drop table wm_outgoing_messages cascade constraints;

drop table wm_headers cascade constraints;
drop table wm_attachments cascade constraints;
drop table wm_messages cascade constraints;
drop table wm_mailboxes cascade constraints; 
drop table wm_email_user_map cascade constraints;
drop table wm_domains cascade constraints;
