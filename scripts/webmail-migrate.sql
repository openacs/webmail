-- The following procedure is handy for copying existing mail from 
-- an old webmail account to a new 4.0 account (in a seperate tablespace).
-- Note that the new user's account must already have been created.
-- This system also uses the old message ids, therefore the migration
-- must be done before receiving any new messages into the new tables..
-- After the migration is done, you must start the wm_global_sequence at 
-- a number greater than the largest msg_id 
-- (i.e.  create sequence wm_global_sequence start with 1000000 )

create or replace procedure wm_migrate_user (
  old_user_id  in integer, 
  new_user_id  in integer)
as
  cursor cur is
    select name, mailbox_id from oldmail.wm_mailboxes where creation_user=old_user_id;
  new_mb_id integer;

begin
  for cur_val in cur
    loop
      begin
        select mailbox_id into new_mb_id from wm_mailboxes 
          where user_id=new_user_id and name=cur_val.name;
        exception
 	  when no_data_found then
	    select wm_global_sequence.nextval into new_mb_id from dual;
	    insert into wm_mailboxes (mailbox_id, name, user_id,
	      creation_date)
	      values
              (new_mb_id, cur_val.name, new_user_id, sysdate);
      end;

     insert into wm_messages (msg_id, mailbox_id, body, mime_text, message_id, msg_size,
         seen_p, answered_p, flagged_p, deleted_p, draft_p, recent_p)
     select wm.msg_id, new_mb_id, body, mime_text, message_id, 0,
         seen_p, answered_p, flagged_p,deleted_p,draft_p, recent_p
       from oldmail.wm_messages wm, oldmail.wm_message_mailbox_map mm
       where wm.msg_id =  mm.msg_id and mm.mailbox_id = cur_val.mailbox_id;

     insert into wm_headers (msg_id, name, value, sort_order)
       select wh.msg_id, name, value, sort_order 
         from oldmail.wm_headers wh, oldmail.wm_message_mailbox_map mm
         where wh.msg_id = mm.msg_id and mm.mailbox_id = cur_val.mailbox_id;

     update wm_messages m set date_value = 
     (select time_value from oldmail.wm_headers h
       where h.msg_id=m.msg_id 
       and lower(h.name)='date'
       and rownum = 1),
     msg_size = greatest(ceil(dbms_lob.getlength(m.body)/1024), 1)
     where mailbox_id = new_mb_id
       and m.msg_size = 0;

     update wm_messages m set to_value = 
     (select substr(value,0,150) from wm_headers h
      where h.msg_id=m.msg_id 
      and lower(h.name)='to'
      and rownum = 1)
     where mailbox_id =new_mb_id;

     update wm_messages m set from_value = 
     (select substr(value,0,150) from wm_headers h
      where h.msg_id=m.msg_id 
      and lower(h.name)='from'
      and rownum = 1)
     where mailbox_id =new_mb_id;

     update wm_messages m set subject_value = 
     (select substr(value,0,150) from wm_headers h
      where h.msg_id=m.msg_id 
      and lower(h.name)='subject'
      and rownum = 1)
     where mailbox_id = new_mb_id;
      end loop;
end;
/
show errors


-- Messages imported from an old webmail installation will have to be 
-- re-parsed to be displayed correctly.  The following function will re-parse
-- a user's mail.

create or replace procedure wm_reparse_user (new_user_id in integer)
as
  cursor cur is
    select msg_id from wm_messages where mailbox_id in 
      (select mailbox_id from wm_mailboxes where user_id = new_user_id);
begin
  for cur_val in cur
    loop
      webmail.reparse_message_from_db(cur_val.msg_id);
    end loop;
end;
/
show errors
