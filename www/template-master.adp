<html>
<head>
<title>Webmail</title>
</head>
<body bgcolor="white" text="black" link=#0000cc vlink=#0000cc>
<table width="100%" border="0">
  <tr>
    <td colspan=2 bgcolor="#CCCCCC"><b>
      @context@ </b>
    </td>
  </tr><tr>
    <td width=150 valign=top bgcolor="#CCCCCC">
      <table width=150 height=500>
        <tr>
          <td width=150 valign=top> <br>
	    <b><a href="clear-cache-mailbox?mailbox_id=@inbox_id@&page_num=1">Check Mail</a></b><br>
	    <a href="message-send">Compose</a><br>
            <a href="preferences">Preferences</a><br>
	    <a href="folder-index">Folders</a><br>
            <a href="manage-views">Views</a><br>
            <a href="index-search">Search</a><br><br>

	  <if @show_mailbox_info@ eq "f">
            <table>
	      <font size=-1>
	      <tr>	  
	        <th align=left><font size=-1>Mailbox</font></th>
	      </tr>
	      <multiple name="mailboxes">
	      <tr>
	        <td><font size=-1>
	          <a href="index?mailbox_id=@mailboxes.mailbox_id@">@mailboxes.name@</a>
	        </font></td>
              </tr>
	      </multiple>
	    </table>
	  </if>
	  <else>
            <table>
	      <font size=-1>
	      <tr>	  
	        <th align=left><font size=-1>Mailbox</font></th>
		<th align=left><font size=-1>Unread</font></th>
	        <th align=left><font size=-1>Total</font></th>
	      </tr>
	      <multiple name="mailboxes">
	      <tr>
	        <td><font size=-1>
	          <a href="index?mailbox_id=@mailboxes.mailbox_id@">@mailboxes.name@</a>
	        </font></td>
                <td align=center><font size=-1>@mailboxes.unread@</font></td>
	        <td align=center><font size=-1>@mailboxes.total@</font></td>
              </tr>
	      </multiple>
	    </table>
	  </else>
            <br>
	    <if @views:rowcount@ ne 0>
	    <table width=100>
	      <tr>
	        <th align=left><font size=-1>Views</font></th>
              </tr>
	      <multiple name="views">
	      <tr>
	        <td><font size=-1>
		  <a href="clear-cache-view?view_id=@views.view_id@">@views.name@</a></font>
		</td>
              </tr>
	      </multiple>
	    </table>
	    </if>
          </td>
        </tr>
      </table>
    </td>
    <td align=left valign=top width="100%">
      <slave>
    </td>
  </tr>
</table>
</body>
</html>
