<master src="template-master">
<property name="context">@context;noquote@</property>

<table border=0 cellspacing=1 cellpadding=4>
  <tr>
    <th align=left bgcolor="#cccccc">Name</th>
    <th align=left bgcolor="#cccccc">&nbsp;Messages &nbsp;</th>
    <th align=left bgcolor="#cccccc">&nbsp;Size &nbsp;</th>
    <th align=left bgcolor="#cccccc" colspan=3>&nbsp;</th>
  </tr>

  <multiple name="mailboxes">
    <tr>
      <td><a href="index?mailbox_id=@mailboxes.mailbox_id@">@mailboxes.name@</a></td>
      <td align=right>@mailboxes.num_msgs@</td>
      <td align=right>@mailboxes.total_size@ Kb</td>
      <td><a href="folder-change?action=Empty&mailbox_id=@mailboxes.mailbox_id@">Empty</a></td>
      <if @mailboxes.reserved@ eq "0">
        <td><a href="folder-change?action=Rename&mailbox_id=@mailboxes.mailbox_id@">Rename</a></td>
        <td><a href="folder-change?action=Delete&mailbox_id=@mailboxes.mailbox_id@">Delete</a></td>
      </if>
      <else>
	<td>&nbsp;</td><td>&nbsp;</td>
      </else>	
    </tr>
  </multiple>
  <tr>
    <th align=left bgcolor="#cccccc">Totals:</th>
    <td bgcolor="#cccccc" align=right>@message_total@</td>
    <td bgcolor="#cccccc" align=right>@size_total@ Kb</td>
    <td bgcolor="#cccccc" colspan=3>&nbsp;</th>
  </tr>
</table>


<br>
<form action="folder-create-2" method=POST>
<input type="hidden" name="target" value="@target@">
Create New Folder: <input type=text size=30 name=folder_name maxlength=50><br>
</form>
<br>




