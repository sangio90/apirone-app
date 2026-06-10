<cfcomponent accessors="true">

	<cffunction name="createOrConditions" access="public" returntype="string" output="false">
        <cfargument name="str" type="string" required="true">
        <cfargument name="fields" type="any" required="true">

        <cfset var searchTerms = listToArray(trim(arguments.str), " ")>
        <cfset var columnArray = isArray(arguments.fields) ? arguments.fields : listToArray(arguments.fields)>

		<cfset result = "(">
		<cfset termIndex = 0>

		<cfloop array="#searchTerms#" index="term">
			<cfset termIndex++>
			<cfset trimmedTerm = trim(term)>

			<cfif len(trimmedTerm)>
				<cfsavecontent variable="columnConditions">
					<cfoutput>
						<cfset columnCount = arrayLen(columnArray)>
						<cfset colIndex = 0>

						<cfloop array="#columnArray#" index="columnName">
							<cfset colIndex++>
							<cfset trimmedColumn = trim(columnName)>

							#trimmedColumn# ILIKE <cfqueryparam cfsqltype="varchar" value="%#trimmedTerm#%">

							<cfif colIndex LT columnCount>
								OR
							</cfif>
						</cfloop>
					</cfoutput>
				</cfsavecontent>

				<cfif termIndex NEQ 1>
					<cfset result = result & " AND ">
				</cfif>

				<cfset result = result & " ( " & trim(columnConditions) & " ) ">
			</cfif>
		</cfloop>

		<cfset result = result & ")">

        <cfreturn result>
    </cffunction>


	<!---
		CONVERTERS FROM JSONB
	---->

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

	<cffunction access="private" name="getMethodsAsArray" returntype="Array">
		<cfargument name="methods" required="true">

		<cfset var items = []>

		<cfif IsArray( arguments.methods )>
			<cfloop array="#arguments.methods#" item="local.thisItem">
				<cfset items.add( local.thisItem.getId() )>
			</cfloop>
		</cfif>

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

	<cffunction access="private" name="getAttributesAsArray" returntype="Array">
		<cfargument name="attributes" required="true">

		<cfset var items = []>

		<cfloop array="#arguments.attributes#" item="local.thisItem">
			<cfset items.add( local.thisItem.getId() )>
		</cfloop>

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

	<!---
		// CONVERTERS
	---->

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

	<cffunction access="private" name="getQueryLoader" returntype="Struct">

		<cfset var loader = server["wirebox-apirone"].getInstance("QueryLoader")>

		<cfreturn loader>

	</cffunction>

	<!---
		Helper per letture batch. Ogni DAO concreto che implementa readByIds() può
		delegare a questi metodi passando il nome tabella, la colonna PK e l'array di ID.
	--->
	<cffunction access="private" name="$readByIdsUuid" returntype="Query">
		<cfargument name="table" type="String" required="true">
		<cfargument name="pkColumn" type="String" required="true">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList(arguments.ids)>

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM #arguments.table#
			WHERE #arguments.pkColumn#::varchar IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="varchar">
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction access="private" name="$readByIdsInteger" returntype="Query">
		<cfargument name="table" type="String" required="true">
		<cfargument name="pkColumn" type="String" required="true">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList(arguments.ids)>

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM #arguments.table#
			WHERE #arguments.pkColumn# IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="integer">
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cfscript>
	private function getRealIP(){

        var headers = GetHTTPRequestData().headers;

        if ( StructKeyExists( headers, "x-cluster-client-ip" ) ) {
			return headers[ "x-cluster-client-ip" ];
		}
		if ( StructKeyExists( headers, "X-Forwarded-For" ) ) {
			return headers[ "X-Forwarded-For" ];
		}

		return Len( CGI.REMOTE_ADDR ) ? Trim( listFirst( CGI.REMOTE_ADDR ) ) : "999.999.999.999";

    }
	</cfscript>

</cfcomponent>
