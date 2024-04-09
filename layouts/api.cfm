<cfcontent reset="true">
<cfheader name="Content-Type" value="application/json">
<cfheader statuscode="#event.getResponse().getStatusCode()#">
<cfoutput>#SerializeJSON( event.getResponse().getData() )#</cfoutput>