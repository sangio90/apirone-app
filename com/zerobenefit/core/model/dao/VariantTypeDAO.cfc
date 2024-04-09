<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="variantTypeId" type="String" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			SELECT *
			FROM variant_types
			WHERE variant_type_id = <cfqueryparam cfsqltype="varchar" value="#arguments.variantTypeId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="insert" returntype="String">

		<cfargument name="variantType" type="com.apirone.core.model.bean.VariantType" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			INSERT INTO variant_types (
				variant_type
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.variantType.getName()#">
			) RETURNING variant_type_id
		</cfquery>
	
		<cfreturn q.variant_type_id>
	</cffunction>

	<cffunction returntype="Query" name="find">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="orderby">
		<cfargument name="code" type="String" >

        <cfquery name="local.q" datasource="zerobenefit">
			SELECT
				variant_type_id,
				COUNT(variant_type_id) OVER() AS total
			FROM
				variant_types
			WHERE 1=1
			
			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				LIMIT  
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET 
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>	

</cfcomponent>