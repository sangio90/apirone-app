<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="variantId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				verticale_variants
			WHERE
				TRIM( varcod ) = <cfqueryparam cfsqltype="varchar" value="#arguments.variantId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="rawProductId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="codvar.varcod">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				varcod,
				COUNT(varcod) OVER() AS total
			FROM
				verticale_variants AS codvar

				<cfif !IsNull( arguments.rawProductId )>
					INNER JOIN
						verticale_variant_products AS comvar
							ON comvar.cbcodvar = codvar.varcod
				</cfif>

			WHERE 1=1

				<cfif !IsNull( arguments.rawProductId )>
					AND cbcodart = <cfqueryparam value="#arguments.rawProductId#" cfsqltype="varchar">
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
