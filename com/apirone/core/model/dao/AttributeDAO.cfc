<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

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

	<cffunction name="find" returntype="Query">

        <cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				attributes
            ORDER BY 
                attribute_id
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="insert" returntype="String">

		<cfargument name="attribute" type="com.apirone.core.model.bean.Attribute" required="true">

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO attributes (
				attribute_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.attribute.getId()#">
			)
			
		</cfquery>

		<cfreturn arguments.attribute.getId()>

	</cffunction>

</cfcomponent>