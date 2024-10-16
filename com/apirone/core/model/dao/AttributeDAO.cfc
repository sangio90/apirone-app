<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="attributeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				attributes
			WHERE
				attribute_id = <cfqueryparam cfsqltype="varchar" value="#arguments.attributeId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="find">

        <cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				attributes
            ORDER BY 
                attribute_id
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>