<cfset code = DateTimeFormat(now(), 'yyyy-mm-dd_HH-nn-ss') & '_' & RandRange(0, 99999)>
<cfset dayPath = DateTimeFormat(now(), 'yyyy/mm')>

<cfsavecontent variable="report">
    <cfinclude template="/coldbox/system/exceptions/BugReport.cfm">
</cfsavecontent>

<cfset path = ExpandPath("/../repository/private/errors/#dayPath#")>
<cfset DirectoryCreate( path, true, true )>

<cffile action="write" file="#path#/#code#.html" output="#report#">

<cfoutput>
    
    <div style="padding:10px">
        <h2 style="padding:0;margin:0;padding-bottom: 6px">Error 500</h2>
        <span>Code: #code#</span>
    </div>

    <hr>

    <!--- <cfif IsDefined("prc.isDev") AND prc.isDev> --->
        #report#
    <!--- </cfif> --->

</cfoutput>
