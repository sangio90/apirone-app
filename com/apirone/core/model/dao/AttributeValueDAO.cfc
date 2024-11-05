<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="attributeValueId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				attribute_values
			WHERE
				attribute_value_id = <cfqueryparam cfsqltype="Integer" value="#arguments.attributeValueId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String">
		<cfargument name="attributeId" type="String">
		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">

        <cfquery name="local.q" datasource="apirone">
			SELECT 
				attribute_value_id,
				COUNT(attribute_value_id) OVER() AS total
			FROM
                attribute_values
			WHERE 1=1
				<cfif !IsNull( arguments.attributeId )>
					AND attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">
				</cfif>
            ORDER BY 
                orderby
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="insert" returntype="Numeric">

		<cfargument name="value" type="com.apirone.core.model.bean.AttributeValue" required="true">

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO attribute_values (
				status_id,
				orderby,
				attribute_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.value.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.value.getOrderBy()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.value.getAttributeId()#">
			) RETURNING attribute_value_id
		</cfquery>

		<cfreturn local.q.attribute_value_id>

	</cffunction>


	<cffunction name="update" returntype="Numeric">

		<cfargument name="value" type="com.apirone.core.model.bean.AttributeValue" required="true">

        <cfquery name="local.q" datasource="apirone">
			UPDATE attribute_values 
			SET
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.value.getStatus().getId()#">,
				orderby = <cfqueryparam cfsqltype="Integer" value="#arguments.value.getOrderBy()#">
			WHERE
				attribute_value_id = <cfqueryparam cfsqltype="Integer" value="#arguments.value.getId()#">
		</cfquery>

		<cfreturn arguments.value.getId()>

	</cffunction>

</cfcomponent>