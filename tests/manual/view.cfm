<cffunction name="template">
    <cfargument required="true" type="String" name="view">

    <cfreturn Replace( view( view="#arguments.view#" ), "nmscript", "script", "ALL" )>
</cffunction>

<cfset template("ciao")>