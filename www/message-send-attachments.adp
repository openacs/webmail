
<html>
<HEAD>
<TITLE>Attachments</TITLE>
</HEAD>
<body bgcolor="white">

<Center><h2>Attachments</h2></center>


<if @creation_user@ ne @user_id@>
    <center><b>The message you which to add attachments does not exists.
    You may have waited to long and it was cleaned up.  
    Please close this window and start a new message.</b></center>
</if>
<else>

<form enctype=multipart/form-data 
  action="message-send-add-attachment.tcl" method=POST>

<input type=hidden name=outgoing_msg_id 
              value="@outgoing_msg_id@">


<TABLE WIDTH=100% CELLPADDING="5" CELLSPACING="0" BORDER="0">
<TR>
<TD valign=top>1.</TD>
<TD colspan="2">Click the <B>Browse</B> button to select the file that you want to attach, or type the path to the file in the box below.</TD>
</TR>
<TR>
<TD valign=top>&nbsp;</TD>
<TD><B>Attach File:</B> &nbsp;<input type="file" name="upload_file"></TD>
</TR>
<TR>
<TD colspan="3"><HR width=95%></TD>
</TR>
<TR>
<TD valign=top>2.</TD>
<TD colspan="2">Click the <B>Attach to Message</B> button.<BR>The transfer of an attached file may require 30 seconds to up to 10 minutes.</TD>
</TR>
<TR>
<TD valign=top>&nbsp;</TD>
<TD colspan="2">
<center><input type="submit" value="Attach to Message">
</center></TD>
</TR>
<TR>
<TD colspan="3"><HR width=95%></TD>
</TR>
<TR>
<TD valign=top>3.</TD>
<TD colspan="2">Repeat Steps 1 and 2 to attach additional files.  Click the <B>Done</B> button to return to your message.</TD>
</TR>
<TR>
<TD valign=top>&nbsp;</TD>
<TD colspan="2">
<center>
<input type=button name=DBack value=" Done " onclick="window.close();
opener.document.message_form.attachments.value='<multiple name="attachments">
<if @attachments.rownum@ ne 1>,</if>@attachments.filename@ (@attachments.att_size@k)</multiple>';">
</center></td>
</TR>
</table>
</form>

<form action="message-remove-attachment.tcl" method=POST>
<input type=hidden name=outgoing_msg_id 
              value="@outgoing_msg_id@">

<table width=100% cellpadding=10 border=0 cellspacing=0>
<tr>
<td bgcolor=#CCCCCC>
&nbsp;<SELECT multiple size=5 name="attachments">              
<OPTION value="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-- Attached Files --&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<multiple name="attachments">
  <option value="@attachments.sort_order@">@attachments.filename@ (@attachments.att_size@k)
</multiple>
</SELECT>
</td>
<td bgcolor=#CCCCCC>
<input type="submit" name="" value="Remove">
</td>
</tr>
</TABLE>
</form>

</else>
</body>
</html>
