<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction returntype="Query" name="read">
		<cfargument name="priceTypeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT entities::varchar, methods::varchar, *
			FROM price_types
			WHERE price_type_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.priceTypeId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="entityId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="50">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				price_type_id,
				COUNT(price_type_id) OVER() AS total
			FROM
				price_types
			WHERE 1=1

			<cfif !IsNull( arguments.entityId )>
				AND jsonb_exists( entities, <cfqueryparam value="#UCase( arguments.entityId )#" cfsqltype="Varchar"> )
			</cfif>

			<cfif !IsNull( arguments.str )>
				AND price_type ILIKE <cfqueryparam value="#arguments.str#" cfsqltype="varchar">
			</cfif>

			<cfif !IsNull( arguments.productId )>
				AND status_id = <cfqueryparam value="#arguments.statusId#" cfsqltype="varchar">
			</cfif>

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
