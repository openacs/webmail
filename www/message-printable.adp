<html>
<title>Webmail</title>
<body>

<blockquote>
<multiple name="headers">

  <if @headers.name@ eq "Subject">
    <b>Subject</b>: <b><%=[ad_quotehtml @headers.value@]%></b><br>
  </if>
  <if @headers.name@ ne "Subject">
    <b>@headers.name@</b>: <%=[ad_quotehtml @headers.value@]%><br>
  </if>
</multiple>

<multiple name="refs">
  <if @refs.rownum@ eq 1>
    <b>References</b>:
  </if>
  <a href="message-printable?msg_id=@refs.ref_msg_id@">@refs.count@</a>
  <if @refs.rownum@ eq @refs:rowcount@><br></if>
</multiple>

<p>
@final_msg_body@
</blockquote>

</body>
</html>