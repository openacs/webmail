
<master src="template-master">
<property name="context">@context;noquote@</property>

<br><br>
<form action="create-view" method=POST>
@form_vars;noquote@

View Name: <input type=text size=50 name="view_name" maxlength=50>
<br>

</form>
