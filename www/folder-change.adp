<master src="template-master">
<FONT face="verdana">
<property name="context">@context@</property>


<if @action@ eq "Rename">
  <form action="folder-rename-2" method=POST>
  @form_vars@
    
  Rename <b>@folder_name@</b> to: 
  <input type=text size=50 name=folder_name maxlength=50><br>
</if>
<if @action@ eq "Delete">
  <br>
  <center><b>Do you really want to delete the folder "@folder_name@"?</b>
  </center>
  <form action="folder-change-2" method=POST> 
  @form_vars@
</if>
<if @action@ eq "Empty">
  <br>
  <center><b>Do you really want to empty the folder "@folder_name@"
  (delete its contents)?</b>
  </center>
  <form action="folder-change-2" method=POST> 
  @form_vars@
</if>


<br>
<center><input type="submit" name="action2" value="@action@">&nbsp;&nbsp;
<input type="submit" name="action2" value="Cancel"></center>
</form>
