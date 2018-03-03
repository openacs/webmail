

<master src="template-master">
<property name="context">@context;noquote@</property>

<FONT face="verdana">


<blockquote>
<table width="600">
<form method=post action=preferences-2>

<tr>

  <td>How many messages should we display per page?</td>
  <td><input type=text name="messages_per_page" size=3 maxlength=3
             value="@messages_per_page@"></td>
</tr><tr>

  <td>From Name: <font size=-1>(as you would like it to appear in the from field of messages)</font></td>
  <td><input type=text name="from_name" size=30 maxlength=300
             value="@from_name@"></td>
</tr><tr>

  <td>Reply-to: <font size=-1>(if different from your Webmail address)</font></td>
  <td><input type=text name="reply_to" size=30 maxlength=300
             value="@reply_to@"></td>
</tr><tr>

  <td>Automatically save sent messages? </td>
  <td>
    <input type=radio name="auto_save_p" value="t" <if @auto_save_p;literal@ true>checked</if>> Yes &nbsp;
    <input type=radio name="auto_save_p" value="f" <if @auto_save_p;literal@ false>checked</if>> No 
  </td>
</tr><tr>

  <td>Give confirmation page for sent messages? </td>
  <td>
    <input type=radio name="confirmation_p" value="t" <if @confirmation_p;literal@ true>checked</if>> Yes &nbsp;
    <input type=radio name="confirmation_p" value="f" <if @confirmation_p;literal@ false>checked</if>> No 
  </td>
</tr><tr>

  <td>Use signature as default?</td>
  <td>
    <input type=radio name="signature_p" value="t" <if @signature_p;literal@ true>checked</if>> Yes &nbsp;
    <input type=radio name="signature_p" value="f" <if @signature_p;literal@ false>checked</if>> No 
    &nbsp;&nbsp;<input type=button value="Edit Signature" onclick="window.open('signature-add', 'signature','toolbar=no,status=no,menubar=no,scrollbars=no,resizable=yes,copyhistory=no,width=600,height=300');">
  </td> 
</tr><tr>

  <td>Move to index upon message delete? </td>
  <td>
    <input type=radio name="delete_move_index_p" value="t" <if @delete_move_index_p;literal@ true>checked</if>> Yes &nbsp;
    <input type=radio name="delete_move_index_p" value="f" <if @delete_move_index_p;literal@ false>checked</if>> No 
  </td>
</tr><tr>

  <td>Forward Address: </td>
  <td><input type=text name="forward_address" size=30 maxlength=300
             value="@forward_address@"></td>
</tr><tr>

  <td>Turn forwarding to the above address on? </td>
  <td>
    <input type=radio name="forward_p" value="t" <if @forward_p;literal@ true>checked</if>> Yes &nbsp;
    <input type=radio name="forward_p" value="f" <if @forward_p;literal@ false>checked</if>> No 
  </td>
</tr>
<if @timezones:rowcount@ ne 0>
<tr>
  <td>What timezone are you in? </td>
  <td>
    <select name="timezone" size="10">
    <if @client_offset@ not nil>
      <option value="@client_time_zone@" selected>@client_time_zone@ @client_offset@</option>
      <option value=""> ------------------------ </option>	
    </if>
      <multiple name="timezones">
        <option value="@timezones.tz@">@timezones.entry@</option>
      </multiple>
    </select>
  </td>
</tr>
</if><else>
  <input type="hidden" name="timezone" value="GMT">
</else>
<tr>
  <td colspan=2>
    <input type=submit value="Save preferences">
  </td>
</tr>
</form>
</table>
</blockquote>
