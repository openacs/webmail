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

  function SaveView() {
    open('view-name.html', 'signature','toolbar=no,status=no,menubar=no,scrollbars=no,resizable=yes,copyhistory=no,width=450,height=150');
  }

// -->
</script>

<table border=0 cellpadding="0" cellspacing=0 width="100%">
<tr bgcolor="#cccccc">
  <td align=left>
    <if @n_messages_comma@ eq 1>1 message, 
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
  </td>
</tr>
</table>

<if @customize@ eq "t">
  <form name="search-form"action="process-search" method=POST>
    <include src="util-pages/constraint-form" edit_filter_id="@view_id;noquote@" num_per_line="5" no_text="t">
    &nbsp;&nbsp;&nbsp;&nbsp;
    <input type=submit name="action" value="Search"> 
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type=submit name="action" value="Save View">
  </form>
</if><else>
  <br>
</else>

<table width="100%">
  <tr>
    <td><h3>VIEW: @view_name@</h3>
    <if @customize@ ne "t">
      <a href="index-view?view_id=@view_id@&customize=t">Customize View</a>
    </if><else>
      <a href="index-view?view_id=@view_id@">Hide View Criteria</a>
    </else>
    </td>
    <td align=right>
    <form name=messageList action="process-selected-messages" method=POST>
    <font size=-1>
    <input type=hidden name=return_url value="clear-cache-view?view_id=@view_id@">
    Selected Msgs:<input type=submit name=action value="Delete">
    <input type=submit name=action value="Refile"> 
    <select name=mailbox_id <if @message_count@ gt 20>onChange="SynchMoves(1)"</if>>
      <include src="util-pages/mailbox-options">
    <option value="@NEW">New Folder</option>
    </select>
    </font>
  </td></tr>
</table>

<p>
<if @message_count@ eq 0>
    <font face="verdana" size=-1>No Messages</font>
</if>
<else>
    <font face="verdana" size="-1">
    <a href="javascript:SetChecked(1)">Check All</a> - <a href="javascript:SetChecked(0)">Clear All</a>
    </font>
    @message_headers@
  
  <br>
  <if @message_count@ gt 20>
  <table border=0 width="100%">
  <tr valign=top>
    <td align=left>
      <font face="verdana" size="-1"><a href="javascript:SetChecked(1)">Check All</a> - <a href="javascript:SetChecked(0)">Clear All</a>
    </td>
    <td align=right>
      <font size=-1>
      Selected Msgs:<input type=submit name=action value="Delete">
      <input type=submit name=action value="Refile"> 
      <select name=mailbox_id2 onChange="SynchMoves(2)">
	<include src="util-pages/mailbox-options">
      <option value="@NEW">New Folder</option>
      </select>
      </font>
    </td>
    </tr>
    <tr bgcolor="#cccccc">
      <td colspan="2" align="right">
        <include src="util-pages/page-links" n_messages="@n_messages;noquote@" cur_page="@page_num;noquote@" msg_per_page="@msg_per_page;noquote@" url="@url;noquote@">
      </td>    
  </tr>
  </table>
  </if>
  </else>
</form>



 

