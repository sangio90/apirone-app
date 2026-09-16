<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">
		<cfargument name="colorId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">

			SELECT *
			FROM
				verticale_colors
			WHERE
				TRIM( clcodice ) = <cfqueryparam cfsqltype="varchar" value="#arguments.colorId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="rawProductId" type="String">
		<cfargument name="variantId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="clcodice">

		<cfquery name="local.q" datasource="apirone" result="local.result">
			SELECT
				clcodice
			FROM
				verticale_colors colori

				<cfif !IsNull( arguments.rawProductId )>
					INNER JOIN verticale_color_products comcol ON comcol.clcodcol = colori.clcodice
				</cfif>

			WHERE 1=1

				<cfif !IsNull( arguments.rawProductId )>
					AND comcol.clcodart = <cfqueryparam value="#arguments.rawProductId#" cfsqltype="varchar">
				</cfif>

			UNION ALL

			SELECT
				clcodcol AS clcodice
			FROM
				verticale_color_variant_products colori

			WHERE 1=1

				<cfif !IsNull( arguments.variantId )>
					AND colori.clcodvar = <cfqueryparam value="#arguments.variantId#" cfsqltype="varchar">
				</cfif>
				<cfif !IsNull( arguments.rawProductId )>
					AND colori.clcodart = <cfqueryparam value="#arguments.rawProductId#" cfsqltype="varchar">
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
