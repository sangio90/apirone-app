<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="lineId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				lines
			WHERE
				line_id = <cfqueryparam cfsqltype="varchar" value="#arguments.lineId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	
	<cffunction returntype="Query" name="find">

        <cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				lines
            ORDER BY 
                orderby
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>