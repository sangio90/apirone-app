<cfcomponent accessors="true">
	<cffunction access="private" name="getLinesAsArray" returntype="Array">
		<cfargument name="lines" required="true">

		<cfset var items = []>

		<cfif IsArray( arguments.lines )>
			<cfloop array="#arguments.lines#" item="local.thisItem">
				<cfset items.add( local.thisItem.getId() )>
			</cfloop>
		</cfif>

		<cfreturn items.len() ? items : NullValue()>
	</cffunction>

	<cffunction access="private" name="getCategoriesAsArray" returntype="Array">
		<cfargument name="categories" required="true">

		<cfset var items = []>

		<cfloop array="#arguments.categories#" item="local.thisItem">
			<cfset items.add( local.thisItem.getId() )>
		</cfloop>

		<cfreturn items.len() ? items : NullValue()>
	</cffunction>

	<cffunction access="private" name="getEntitiesAsArray" returntype="Array">
		<cfargument name="entities" required="true">

		<cfset var items = []>

		<cfloop array="#arguments.entities#" item="local.thisItem">
			<cfset items.add( local.thisItem.getId() )>
		</cfloop>

		<cfreturn items.len() ? items : NullValue()>
	</cffunction>

	<cffunction name="sanitizeSQL" returntype="String">
		<cfargument name="sql" type="String">

		<cfreturn ReReplace( arguments.sql, "[^A-Za-z0-9_ ,.]", "", "all" )>
	</cffunction>

	<cffunction name="getDBField" returntype="Struct">
		<cfargument name="field" type="String" required="true">

		<!--- TODO: Loaded from wirebox not works. --->
		<cfset var DBUtil = new com.apirone.core.util.DBUtil()>

		<cfreturn DBUtil.getDBField( arguments.field )>
	</cffunction>

	<cffunction name="getCompleteSQL" returntype="String">
		<cfargument name="queryResult" type="Struct" required="true">

		<cfset var DBUtil = new com.apirone.core.util.DBUtil()>

		<cfreturn DBUtil.getCompleteSQL(
			sql    = arguments.queryResult.sql,
			params = arguments.queryResult.sqlparameters
		)>
	</cffunction>

	<cffunction name="getConfig" returntype="Struct">
		<cfset var result = { datasource = request.datasource }>

		<cfreturn result>
	</cffunction>
</cfcomponent>
