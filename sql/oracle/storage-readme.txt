# /webmail/sql/storage-readme.txt
# @author Erik Bielefeldt (erik@arsdigita.com)
# @creation-date 2001-02-07
# @cvs_id $Id$

Because Webmail is centered around a few heavily used tables, 
I thought that giving the dba some idea of the sizes of these 
tables would help in setting up appropriate tablespaces
and storage clauses for Webmail.  

I have included a table of all the tables and indexes created by 
the Webmail package, and their approximate sizes PER ROW of data.
Obviously, you must first come up with some expectations on 
usage and table size first.  

The most important items to pay attention to are WM_MESSAGES,WM_HEADERS,
and WM_HEADERS_BY_MSG_ID_NAME.  I highly recommend a suitable storage 
clause for these to avoid a large amount of fragmentation.  You should
also consider storing the lobs from these tables in seperate tablespaces.

I haven't really had problems with chained rows using pctfree 10%.


Name					 Type       Suggested size PER ROW (bytes)
------------------------TABLES----------------------------------------
WM_EMAIL_USER_MAP			 TABLE	    70
WM_MAILBOXES				 TABLE	    32
WM_PREFERENCES				 TABLE	    65
WM_MESSAGES				 TABLE	    1360
  --LOBS (mime_text and body)			    10 Kb
WM_ATTACHMENTS				 TABLE	    default
  --LOBS (this is hard to estimate)		    100 Kb
WM_HEADERS				 TABLE	    100
  -- This table usually grows at about 10 times
  -- the rate of the wm_messages table

WM_DOMAINS				 TABLE	    default
WM_PARSE_ERRORS 			 TABLE	    default
WM_OUTGOING_MESSAGES			 TABLE	    default
WM_OUTGOING_HEADERS			 TABLE	    default
WM_OUTGOING_MESSAGE_PARTS		 TABLE	    default
WM_FILTER_VIEWS 			 TABLE	    default
WM_FILTER_CONSTRAINTS			 TABLE	    default
WM_CACHED_MSGS				 TABLE	    default


-----------------------INDEXES----------------------------------------
WM_EUM_USER_ID_PK			 INDEX	    16
WM_EUM_DOMAIN_USER_UN			 INDEX	    49
WM_MAILBOXES_ID_PK			 INDEX	    15
WM_MAILBOXES_USER_NAME_UN		 INDEX	    24
WM_MESSAGES_ID_PK			 INDEX	    28
WM_MESSAGES_BY_MAILBOX_SEEN		 INDEX	    34
WM_MESSAGES_BY_MAILBOX_DATE		 INDEX	    45
WM_ATT_ATT_ID_PK			 INDEX	    42
WM_MESSAGES_BY_MAILBOX_MSG_ID		 INDEX	    26
WM_MESSAGES_BY_MESSAGE_ID		 INDEX	    27
WM_PREF_USER_ID_PK			 INDEX	    16
WM_HEADERS_BY_MSG_ID_NAME		 INDEX	    28
  -- This is by far the largest index, and you 
  -- should probably give a storage clause to it 
  -- even if you ignore the others.

WM_FILTER_VIEWS_ID_PK			 INDEX	    default
WM_FILTER_VIEWS_BY_USER 		 INDEX	    default
WM_CONSTRAINTS_PK			 INDEX	    default
WM_FILTER_CONSTRAINTS_BY_VIEW		 INDEX	    default
WM_CACHED_MSGS_ID_PK			 INDEX	    default
WM_DOMAINS_SHORT_PK			 INDEX	    default
WM_DOMAINS_FULL_UN			 INDEX	    default
WM_PARSE_ERRORS_FILE_PK 		 INDEX	    default
WM_OUT_MESSAGES_ID_PK			 INDEX	    default
WM_OUTGOING_MSG_BY_USER 		 INDEX	    default
WM_OUTGOING_HEADERS_PK			 INDEX	    default
WM_OMP_PK				 INDEX	    default
