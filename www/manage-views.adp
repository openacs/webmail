<master src="template-master">
<property name="context">@context;noquote@</property>

<b>Existing views:</b>
<ul>
  <if @filters:rowcount@ eq 0>
    <li><i>none</i>
  </if>
<multiple name="filters">
  <li><a href="manage-views?edit_filter_id=@filters.filter_id@">@filters.name@</a><br>
</multiple>
</ul>

<a href="manage-views">Create new view</a>
<hr>

<b>
<if @edit_filter_id@ eq "0">
  Create new view:
</if>
<else>
  Edit filter:
</else>
</b>
<form action="create-view" method=POST>

<%=[export_form_vars edit_filter_id]%>

Name: <input type=text name="view_name" size=50 maxlength=50 value="@filter_name@"> 
<br>
<br>
<include src="util-pages/constraint-form" edit_filter_id="@edit_filter_id;noquote@" num_per_line="2">
<br>
<if @edit_filter_id@ ne 0>
  <a href="delete-view?edit_filter_id=@edit_filter_id@">Delete this view</a>
<br><br>
</if>
<input type=submit name="action" value="<if @edit_filter_id@ eq 0>Create View</if><else>Update View</else>">
</form>
