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

	<cffunction name="insert" returntype="String">

		<cfargument name="value" type="com.apirone.core.model.bean.AttributeValue" required="true">
		<cfargument name="attributeId" type="String" required="true">

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO attribute_values (
				status_id,
				orderby,
				attribute_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.value.getStatus().getId()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.value.getOrderBy()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.attributeId#">
			)
		</cfquery>

		<cfreturn arguments.attribute.getId()>

	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="value" type="com.apirone.core.model.bean.AttributeValue" required="true">
		<cfargument name="attributeId" type="String" required="true">

        <cfquery name="local.q" datasource="apirone">
			UPDATE attribute_values 
			SET
				status_id = <cfqueryparam cfsqltype="varchar" value="#arguments.value.getStatus().getId()#">,
				orderby = <cfqueryparam cfsqltype="varchar" value="#arguments.value.getOrderBy()#">
			WHERE
				attribute_value_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.value.getId()#">
		</cfquery>

		<cfreturn arguments.value.getId()>

	</cffunction>

</cfcomponent>