<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="lineId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT line_id::varchar, *
			FROM
				lines
			WHERE
				line_id = <cfqueryparam cfsqltype="varchar" value="#arguments.lineId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>
	
	<cffunction returntype="Query" name="find">

		<cfargument name="str" type="String">
		<cfargument name="categoryId" type="Numeric">

		<cfquery name="local.q" datasource="apirone">
			SELECT line_id::varchar
			FROM
				lines
			WHERE 1=1
				
				<cfif !IsNull( arguments.categoryId )>
					AND lines.line_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND 
					( 
						lines.line_id ILIKE <cfqueryparam cfsqltype="Varchar" value="#arguments.str#%">
						OR lines.line ILIKE <cfqueryparam cfsqltype="Varchar" value="#arguments.str#%">
					)
				</cfif>

            ORDER BY 
                orderby
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>