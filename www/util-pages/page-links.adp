Page @cur_page@ of @num_pages@ &nbsp;&nbsp;
[
<multiple name="pages">
  <if @pages.number@ eq @cur_page@>
    &nbsp;@pages.number@&nbsp;
  </if>
  <else>
    <a href="@url@page_num=@pages.number@">@pages.number@</a>&nbsp;
  </else>
</multiple>
]