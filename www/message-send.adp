

<master src="template-master">
<property name="context">@context;noquote@</property>
<FONT face="verdana">

<script language=JavaScript>
<!--
  var prevWnd=null;
  function MsgPreview() {
    if (!document.message_form.html_use.checked) {
      alert("You must have the \"allow HTML tags\" checkbox checked to view an HTML preview");
    } else {
      prevWnd=window.open('','prevWnd','width=500,height=600,scrollbars=yes,resizable=yes,status=0');
      prevWnd.document.open();
      prevWnd.document.writeln('<html><title>Message Preview</title><body bgcolor="#cccccc"><center><b>HTML Preview of Message</b>&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:window.close()">Close</a></center><hr><br>');
      prevWnd.document.writeln('<b>To: </b>' + document.message_form.to.value + '<br>');
      prevWnd.document.writeln('<b>Subject: </b>' + document.message_form.subject.value + '<br>');
      if (document.message_form.cc.value!="") {
        prevWnd.document.writeln('<b>Cc: </b>' + document.message_form.cc.value + '<br>');
      }
      if (document.message_form.bcc.value!="") {
        prevWnd.document.writeln('<b>Bcc: </b>' + document.message_form.bcc.value + '<br>');
      }
      prevWnd.document.writeln('<p>'+document.message_form.body.value);
      if (document.message_form.signature_use.checked) {
	prevWnd.document.writeln('<br><br>' + document.message_form.signature.value);
      }
      prevWnd.document.writeln('</body></html>');
      prevWnd.document.writeln('<BR>');
      prevWnd.document.close();
    }
  }

  function EditSig() {
    open('signature-add?update=1', 'signature','toolbar=no,status=no,menubar=no,scrollbars=no,resizable=yes,copyhistory=no,width=600,height=325');
  }

  function EditAttachments() {
    open('message-send-attachments?outgoing_msg_id=@outgoing_msg_id@', 'attachments','toolbar=no,status=no,menubar=no,scrollbars=no,resizable=yes,copyhistory=no,width=400,height=550');
  }
// -->
</script>



<blockquote>

<form action="message-send-2.tcl" method=POST name="message_form">
<input type=hidden value="@signature@" name="signature">
<input type=hidden value="@response_to_msg_id@" name="response_to_msg_id">
<input type=hidden value="@outgoing_msg_id@" name="outgoing_msg_id">
<if @forward_msg_id@ not nil and @forward_style@ ne "inline">
  <input type=hidden value="@forward_msg_id@" name="forward_msg_id">
</if>
<input type=hidden value="@return_url@" name="return_url">
<input type=hidden value="@from@" name="from">

<table border=0 width=90% cellspacing=0 cellpadding=0>
<tr>
  <td bgcolor="white" colspan="2">
    <table border=0 width=100% cellspacing=0 cellpadding=4>
      <tr>
        <td align=right bgcolor="white"><b>To: </b>
	</td>
	<td align=left bgcolor="white"><input type="text" name="to" size="40" value="<%= [philg_quote_double_quotes $to] %>" maxlength="4000">
	</td>
      </tr>

      <tr>
        <td align=right bgcolor="white"><b>Cc: </b>
	</td>
	<td bgcolor="white" align=left>
	  <input type="text" name="cc" size="40" value="<%= [philg_quote_double_quotes $cc] %>" maxlength="4000">
	</td>
      </tr>
      <tr>
        <td align=right bgcolor="white"><b>Bcc: </b>
        </td>
	<td align=left bgcolor="white">
	  <input type="text" name="bcc" size="40" value="<%= [philg_quote_double_quotes $bcc] %>" maxlength="4000">&nbsp;
	</td>
      </tr>

      <tr>
        <td align=right bgcolor="white"><b>Subject: </b>
	</td>
	<td bgcolor="white">
	  <input type="text" name="subject" size="40" value="<%= [philg_quote_double_quotes $subject] %>" maxlength="4000">
	</td>
      </tr>
      <if @forward_msg_id@ not nil and @forward_style@ ne "inline">
      <tr>
	<td align=right bgcolor="white"><b>Note:</b></td>
	<td align=left bgcolor="white"><b>Forwarded message attached.</b></td>
      </tr>
      </if>
    </table>

    <table border=0 width=90% cellspacing=0 cellpadding=4>
      <tr>
        <td align=left bgcolor="white">
	  <textarea wrap="virtual" name="body" rows="20" cols="70">@msg_body@</textarea>
	</td>
      </tr>
      <tr>
        <td>
          <input name="save" type="checkbox" @save_checked@> Save copy of outgoing message &nbsp;&nbsp;
	  <input name="html_use" type="checkbox" @html_checked@> Allow HTML tags
	  &nbsp;&nbsp;
	  <input name="signature_use" type="checkbox" @signature_checked@> Use signature
	  &nbsp;
          <a href="javascript:EditSig()">Edit signature</a>
        </td>
      </tr>
    </table>
  </td>
</tr>
<tr>
  <td bgcolor="#cccccc" align="left">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type=submit name="action" value="Send">
    &nbsp;&nbsp;
    <input type=submit name="action" value="Save Draft">
    &nbsp;&nbsp;
    <a href="javascript:MsgPreview()">HTML Preview of message</a>&nbsp;&nbsp;
  </td>
  <td bgcolor="#cccccc" align="right">
    <input type=submit name="action" value="Cancel">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  </td>
</tr>
</table>


<table border=0 width=90% cellspacing=0 cellpadding=4>
  <tr>
  <td align=right><b>Attachments: </b>
  </td>
  <td>
    <input type="text" name="attachments" size="45">&nbsp;
    <a href="javascript:EditAttachments()">Edit attachments</a>
  </td>
</tr>
</table>
</blockquote>


</form>
