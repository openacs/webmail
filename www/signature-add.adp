<HTML>
<HEAD>
<TITLE>Signature</TITLE>
</HEAD>
<BODY BGCOLOR="#FFFFFF">
<h2>Signature</h2>
<br>
Please edit your signature below and then click "save" to save your signature.
  <form name="sig_form" action="signature-add-2.tcl" method="get">
  <blockquote>
  <table cellpadding=0 cellspacing=0 border=0>
  <tr>
      <td colspan=2><TEXTAREA wrap="virtual" name="signature" rows="5" 
          cols="50">@current_signature@</TEXTAREA>
  </tr>
  <tr>
  <td bgcolor="#cccccc">
    <input type="checkbox" name="html" @html_check@> 
	Allow html tags in signature
  </td>
  <td align=right bgcolor="#cccccc">
  <input type=submit name="action" value="Save" onclick="opener.document.message_form.signature.value=document.sig_form.signature.value;window.location('signature-add-2');">&nbsp;&nbsp;
  <input type=submit name="action" value="Delete">&nbsp;&nbsp;
  </td>
  </tr><tr>
  <td colspan=2 align=center bgcolor="#cccccc">
  <input type="button" value=" Cancel " onclick="window.close();">
  <tr><td colspan=2 align=center bgcolor="#cccccc" >&nbsp;</td></tr>
  </tr>
</table>
</blockquote>
</form>
</BODY>
</HTML>

