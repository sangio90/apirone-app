<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="attributeValueId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				attribute_values
			WHERE
				attribute_value_id = <cfqueryparam cfsqltype="varchar" value="#arguments.attributeValueId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="find">

        <cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
                attribute_values
            ORDER BY 
                orderby
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>