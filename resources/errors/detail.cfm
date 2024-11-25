<cfparam name="url.id" default="notfound">

<cfif ListLen( url.id, '-' ) GT 2>

    <cfset year = ListFirst(url.id, '-')>
    <cfset month = ListGetAt(url.id, 2,'-')>

    <cfset title = "#year#/#month#/#url.id#.html">

    <cfset path = ExpandPath('/../repository/private/errors/#title#')>

    <cfif FileExists( path )>

        <cffile action="read" file="#path#" variable="report">
    
        <cfoutput>
            <h1><span style="font-size:18px">Error:</span> #title#</h1>
            #report#
        </cfoutput>

    <cfelse>
        File not exists
    </cfif>

<cfelse>

    Format of Id uncorrect

</cfif>

