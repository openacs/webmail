Match:&nbsp;
<input type=radio name="and_p" value="t" <if @and_p;literal@ true>checked</if>> all constraints &nbsp;
<input type=radio name="and_p" value="f" <if @and_p;literal@ false>checked</if>> any constraint <br>

<if @no_text@ eq "f">
<br>
Note: select '-' to turn off a constraint.  You may search for empty fields by selecting <br>
the appropriate field, using "matches,"  and leaving the text box blank.<br>
</if>

<multiple name="constr_selected">

  <select name="comp_object.@constr_selected.rownum@">
        <option value="off" <if @constr_selected.comp_object@ eq "off">selected</if>>-</option>
        <option value="subject" <if @constr_selected.comp_object@ eq "subject">selected</if>>Subject</option>
        <option value="body" <if @constr_selected.comp_object@ eq "body">selected</if>>Body</option>
        <option value="from" <if @constr_selected.comp_object@ eq "from">selected</if>>Sender</option>
        <option value="to" <if @constr_selected.comp_object@ eq "to">selected</if>>To</option>
        <option value="cc" <if @constr_selected.comp_object@ eq "cc">selected</if>>Cc</option>
        <option value="header" <if @constr_selected.comp_object@ eq "header">selected</if>>Any Header</option>
  </select>

  <select name="comp_type.@constr_selected.rownum@">
        <option value="contains" <if @constr_selected.comp_type@ eq "contains">selected</if>>contains</option>
        <option value="no_contain" <if @constr_selected.comp_type@ eq "no_contain">selected</if>>doesn't contain</option>
        <option value="matches" <if @constr_selected.comp_type@ eq "matches">selected</if>>matches</option>
        <option value="no_match" <if @constr_selected.comp_type@ eq "no_match">selected</if>>doesn't match</option>
        <option value="starts_with" <if @constr_selected.comp_type@ eq "starts_with">selected</if>>starts with</option>
        <option value="ends_with" <if @constr_selected.comp_type@ eq "ends_with">selected</if>>ends with</option>
  </select>
    <input type=text name="comp_string.@constr_selected.rownum@" size=15 maxlength=100 value="@constr_selected.comp_string@"><br>
</multiple>

Age: <select name="age_type">
        <option value="off" <if @age_type@ eq "off">selected</if>> - </option>
        <option value="more_than" <if @age_type@ eq "more_than">selected</if>> is more than </option>
        <option value="less_than" <if @age_type@ eq "less_than">selected</if>> is less than </option>
        <option value="matches" <if @age_type@ eq "matches">selected</if>> equals </option>
        <option value="no_match" <if @age_type@ eq "no_match">selected</if>> doesn't equal </option></select>
    <input type=text name="age_string" size=4 maxlength=4 value="@age_string@"> days

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

    <input type=radio name="status" value="read" <if @read_string@ eq "read">checked</if>> Read &nbsp;
    <input type=radio name="status" value="unread" <if @read_string@ eq "unread">checked</if>> Unread &nbsp;
    <input type=radio name="status" value="either" <if @read_string@ eq "either">checked</if>> Either &nbsp;
<br>

<if @no_text@ eq "f">
<br>
Limit view to certain mailboxes: (leave unchecked to search all mailboxes)
</if>

<table>
  <multiple name="mailboxes">
  <if @mailboxes.newrow@ eq "t">
  <tr>
  </if>
    <td>
      <input type="checkbox" name="mailboxes" value="@mailboxes.mailbox_id@" @mailboxes.checked@> 
      @mailboxes.name@
    </td>
</multiple>
</table>


