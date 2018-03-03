<master src="template-master">
<property name="context">@context;noquote@</property>

<script language=JavaScript>

<!--
// Necessary for the refile selected buttons. There are two selection widgets
// with the same name in this form. If they are not synched up before the form
// is submitted, only the value of the first one will be used.
 function SynchMoves(primary) {
  dml=document.message_form;
    if(primary==2) dml.mailbox_id.selectedIndex=dml.mailbox_id2.selectedIndex;
    else dml.mailbox_id2.selectedIndex=dml.mailbox_id.selectedIndex;
}
// -->
</script>

<form name="message_form" action="message-process" method=POST>
<table width="90%" cellpadding=0 cellspacing=0>
<tr>
  <td align=left>
    <multiple name="nav_links">
      <if @nav_links.rownum@ ne 1> - </if>
      <if @nav_links.msg_id@ nil>
        <font color="lightgray">@nav_links.name@</font>
      </if><else>
        <a href="message?view_id=@view_id@&msg_id=@nav_links.msg_id@">@nav_links.name@</a>
      </else>
    </multiple>
  </td> 
  <td align=left>
    <if @view_id@ ne 0>
      This message is currently filed in: <b>@mailbox_name@</b>
    </if>
  </td>
  </tr>
<tr>
<td align=left>
  <input type=hidden name="next_msg_id" value="@next_msg_id@">
  <input type=hidden name="msg_id" value="@msg_id@">
  <input type=hidden name="view_id" value="@view_id@">
  <select name="mailbox_id" onChange="SynchMoves(1)"> 
    <option value="" selected>Select Folder</option>
    <include src="util-pages/mailbox-options" exclude_id="@mailbox_id;noquote@"> 
  </select>
  <input type=submit name="action" value="Refile">

<if @deleted_p;literal@ false>
&nbsp;&nbsp;&nbsp;&nbsp;
<input type=submit name="action" value="Delete">
&nbsp;&nbsp;&nbsp;&nbsp;
</if>
  <a href="message-printable?msg_id=@msg_id@&header_display_style=@header_display_style@&body_display_style=@body_display_style@">Printable view</a>


</td></tr>
<tr>
<td align=left valign=center>
  <a href="message-send?return_url=@return_url@&response_to_msg_id=@msg_id@">Reply</a> -
  <a href="message-send?return_url=@return_url@&response_to_msg_id=@msg_id@&respond_to_all=1">Reply All</a> - 
  <a href="message-send?return_url=@return_url@&forward_msg_id=@msg_id@&forward_style=attachment">Forward as Attachment</a> -
  <a href="message-send?return_url=@return_url@&forward_msg_id=@msg_id@&forward_style=inline">Forward Inline</a>
</td>
</tr>
</table>
<hr>
<blockquote>
<multiple name="headers">

  <if @headers.name@ eq "From">
    <b>From</b>: <b><a href=message-send?to=<%=[ns_urlencode @headers.value@]%>><%=[ad_quotehtml @headers.value@]%></a></b><br>
  </if>
  <if @headers.name@ eq "Subject">
    <b>Subject</b>: <b><%=[ad_quotehtml @headers.value@]%></b><br>
  </if>
  <if @headers.name@ ne "Subject" and
      @headers.name@ ne "From">
    <b>@headers.name@</b>: <%=[ad_quotehtml @headers.value@]%><br>
  </if>
</multiple>

<multiple name="refs">
  <if @refs.rownum@ eq 1>
    <b>References</b>:
  </if>
  <a href="message?msg_id=@refs.ref_msg_id@">@refs.count@</a>
  <if @refs.rownum@ eq @refs:rowcount@><br></if>
</multiple>
&nbsp;&nbsp;
  <font size=-1>
  <if @header_display_style@ eq "short">
    <a href="message?<%=[export_url_vars msg_id view_id body_display_style]%>&header_display_style=all">Show all headers</a>
  </if><else>
    <a href="message?<%=[export_url_vars msg_id view_id body_display_style]%>&header_display_style=short">Hide headers</a>
  </else>
  </font>

<if @mime_message_p;literal@ true>
  &nbsp;&nbsp;|&nbsp;&nbsp;
  <font size=-1>
  <if @body_display_style@ eq "parsed">
     <a href="message?<%=[export_url_vars msg_id view_id header_display_style]%>&body_display_style=unparsed">
     Show unparsed message</a>
   </if><else>
     <a href="message?<%=[export_url_vars msg_id view_id header_display_style]%>&body_display_style=parsed">Show decoded message</a>
  </else>
  </font><br>
</if>

<p>
@final_msg_body@
</blockquote>

<hr>
<table width="90%" cellpadding=0 cellspacing=0>
<tr>
<td align=left valign=center>
  <a href="message-send?return_url=@return_url@&response_to_msg_id=@msg_id@">Reply</a> -
  <a href="message-send?return_url=@return_url@&response_to_msg_id=@msg_id@&respond_to_all=1">Reply All</a> - 
  <a href="message-send?return_url=@return_url@&forward_msg_id=@msg_id@&forward_style=attachment">Forward as Attachment</a> -
  <a href="message-send?return_url=@return_url@&forward_msg_id=@msg_id@&forward_style=inline">Forward Inline</a>
</td>
</tr><tr>
<td align=left>

  <select name="mailbox_id2" onChange="SynchMoves(2)">
    <option value="">Select Folder</option>
    <include src="util-pages/mailbox-options" exclude_id="@mailbox_id;noquote@"> 
  </select>
  <input type=submit name="action" value="Refile">

<if @deleted_p;literal@ false>
&nbsp;&nbsp;&nbsp;&nbsp;
<input type=submit name="action" value="Delete">
&nbsp;&nbsp;&nbsp;&nbsp;
</if>
  <a href="message-printable?msg_id=@msg_id@&header_display_style=@header_display_style@&body_display_style=@body_display_style@">Printable view</a>
</td></tr>
<tr>
<td>
    <multiple name="nav_links">
      <if @nav_links.rownum@ ne 1> - </if>
      <if @nav_links.msg_id@ nil>
        <font color="lightgray">@nav_links.name@</font>
      </if><else>
        <a href="message?view_id=@view_id@&msg_id=@nav_links.msg_id@">@nav_links.name@</a>
      </else>
    </multiple>
 </td>
</tr>
</table>
</form>






