<cfcomponent accessors="true">

	<cffunction access="private" name="getCategoriesAsArray" returntype="Array">
		<cfargument name="categories" required="true">

		<cfset var items = []>

		<cfloop array="#arguments.categories#" item="local.thisItem">
			<cfset items.add( local.thisItem.getId() )>
		</cfloop>

		<cfreturn items.len() ? items : NullValue()>
	</cffunction>	


	<cffunction name="sanitizeSQL" returntype="String">

		<cfargument name="sql" type="String">

	    <cfreturn REReplace( arguments.sql , "[^A-Za-z0-9_ ,.]", "", "all" )>

	</cffunction>	


	<cffunction name="getDBField" returntype="Struct">

		<cfargument name="field" type="String" required="true">

		<!----
			TODO: Loaded from wirebox not works.
		---->
		<cfset var DBUtil = new com.apirone.core.util.DBUtil()>

	    <cfreturn DBUtil.getDBField( arguments.field )>

	</cffunction>	

	<cffunction name="getCompleteSQL" returntype="String">

		<cfargument name="sql" type="String" required="true">
		<cfargument name="params" type="Array" required="true">

		<cfset var DBUtil = new com.apirone.core.util.DBUtil()>

	    <cfreturn DBUtil.getCompleteSQL( argumentCollection = arguments )>

	</cffunction>	

</cfcomponent>