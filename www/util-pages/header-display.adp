<multiple name="headers">

  <if @headers.name@ eq "From">
    <b>From</b>: <b><a href=message-send?to=<%=[ns_urlencode @headers.value@]%>><%=[ad_quotehtml @headers.value@]%></a></b><br>
  </if>
  <if @headers.name@ eq "Subject">
    <b>Subject</b>: <b><%=[ad_quotehtml @headers.value@]%></b><br>
  </if>
  <if @headers.name@ ne "Subject" and
      @headers.name@ ne "From">
    <b>@headers.name@</b>: <%=[ad_quotehtml @headers.value@]%><br>
  </if>
</multiple>

<multiple name="refs">
  <if @refs.rownum@ eq 1>
    <b>References</b>:
  </if>
  <a href="message?msg_id=@refs.ref_msg_id@">@refs.count@</a>
  <if @refs.rownum@ eq @refs:rowcount@><br></if>
</multiple>









