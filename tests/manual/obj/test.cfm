<cfset t = new Test()>

<cfdump var="#t#">

<cfdump var="#t.writeId()#">
<cfset t.setId(200)>
<cfdump var="#t.writeId()#">
<cfdump var="#t.writeValue()#">

<cfdump var="#t?.getTest2()?.writeId()#">
