<master src="template-master">
<property name="context">@context;noquote@</property>

<script language=JavaScript>
<!--
 function SetChecked(val) {
  dml=document.messageList;
  len = dml.elements.length;
  var i=0;
  for( i=0 ; i<len ; i++) {
    if (dml.elements[i].name=='msg_ids') {
      dml.elements[i].checked=val;
    }
  }
}

// Necessary for the refile selected buttons. There are two selection widgets
// with the same name in this form. If they are not synched up before the form
// is submitted, only the value of the first one will be used.
function SynchMoves(primary) {
  dml=document.messageList;
  if(primary==2) dml.mailbox_id.selectedIndex=dml.mailbox_id2.selectedIndex;
  else dml.mailbox_id2.selectedIndex=dml.mailbox_id.selectedIndex;
}
// -->
</script>

<table border=0 cellpadding="0" cellspacing=0 width="100%">
<tr bgcolor="#DDDDDD">
  <td align=left>
    <if @n_messages@ eq 1>1 message, 
    </if>
    <else>
      @n_messages_comma@ messages,
    </else>
    <if @n_unread_messages@ eq 1>
       1 unread
    </if>
    <else>
      @n_unread_messages@ unread 
    </else>
  </td>
 <td align="right">
    <include src="util-pages/page-links" n_messages="@n_messages;noquote@" cur_page="@page_num;noquote@" msg_per_page="@msg_per_page;noquote@" url="@url;noquote@">
    <if @mailbox_name;noquote@ eq "TRASH">
      <a href="folder-change-2?action=Empty&action2=Empty&mailbox_id=@mailbox_id@&target=@empty_trash_target@">Empty Trash</a><br>
    </if>
  </td>
</tr>
</table>


<br>
<table border=0 width="100%">
<tr valign=top>
  <td><h3><%=[wm_mailbox_name_for_display @mailbox_name@]%></h3></td>
  <td align=right>
    
  </td>
  <td align=right>
    <form name=messageList action="process-selected-messages" method=POST>
    <font size=-1>
    Selected Msgs:
    <if @mailbox_name@ ne "TRASH">
      <input type=submit name=action value="Delete">
    </if>
    <input type=submit name=action value="Refile">
    <select name=mailbox_id <if @message_count@ gt 20>onChange="SynchMoves(1)"</if>>
      <include src="util-pages/mailbox-options" select_id="@mailbox_id;noquote@">
    <option value="@NEW">New Folder</option>
    </select>
    </font>
  </td>
</tr>
</table>

<p>
<if @message_count@ eq 0>
   <font face="verdana" size=-1>No Messages</font>
</if>
<else>
   <font face="verdana" size="-1">
	&nbsp;<a href="javascript:SetChecked(1)">Check All</a> - <a href="javascript:SetChecked(0)">Clear All</a>
   </font>
    @message_headers@
  
  <br>
  <if @message_count@ gt 25>
  <table border=0 width="100%">
  <tr valign=top>
    <td align=left>
      <font face="verdana" size="-1"><a href="javascript:SetChecked(1)">Check All</a> - <a href="javascript:SetChecked(0)">Clear All</a>
    </td>
    <td align=right>
      <font size=-1>
      Selected Msgs:
      <if @mailbox_name@ ne "TRASH">
        <input type=submit name=action value="Delete">
      </if>
      <input type=submit name=action value="Refile"> 
      <select name=mailbox_id2 onChange="SynchMoves(2)">
	<include src="util-pages/mailbox-options" select_id="@mailbox_id;noquote@">
      <option value="@NEW">New Folder</option>
      </select>
      </font>
    </td>
  </tr>
  <tr bgcolor="#DDDDDD">
    <td colspan="2" align="right">
      <include src="util-pages/page-links" n_messages="@n_messages;noquote@" cur_page="@page_num;noquote@" msg_per_page="@msg_per_page;noquote@" url="@url;noquote@">
      <if @mailbox_name;noquote@ eq "TRASH">
        <a href="folder-change-2?action=Empty&action2=Empty&mailbox_id=@mailbox_id@&target=@empty_trash_target@">Empty Trash</a><br>
      </if>
    </td>
  </tr>
  </table>
  </if>
  </else>
</form>


















