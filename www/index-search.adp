<master src="template-master">
<property name="context">@context@</property>

<h3>Search </h3>
<form action="process-search" method=POST>
<include src="util-pages/constraint-form" edit_filter_id="0" num_per_line="5">
<input type=submit name="action" value="Search">
</form>

