<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="rawProductId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">

			SELECT
				arcodart,
				arsemlav,
				artipmat,
				arcodart,
				ardesart,
				artipmat,
				arunmis1,
				artipcol,
				CASE WHEN artipmat = 'LAV' THEN 'LV' ELSE 'MP' END AS processiong_type_id
			FROM
				verticale_raw_products a
			WHERE
				arcodart = <cfqueryparam cfsqltype="varchar" value="#arguments.rawProductId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!----
a = materia prima
m = prodotto finito
s = semilavorato
artiplav = lav = lavorazioni
---->

	<cffunction returntype="Query" name="find">
		<cfargument name="typeId" type="String">
		<cfargument name="processingTypeId" type="String">
		<cfargument name="str" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="arcodart">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				arcodart,
				ardesart,
				arsemlav,
				artipmat,
				arunmis1,
				COUNT(arcodart) OVER() AS total,
				CASE WHEN artipmat = 'LAV' THEN 'LV' ELSE 'MT' END AS processiong_type_id
			FROM
				verticale_raw_products artico
			WHERE 1=1
				AND arobsole <> 'S'

			<cfif !IsNull( arguments.typeId )>
				AND codtip = <cfqueryparam value="#arguments.typeId#" cfsqltype="varchar">
			</cfif>

			<!--- lavorazioni --->
			<cfif arguments.processingTypeId == "LV">
				AND artipmat = 'LAV'
			</cfif>

			<!--- materie prime --->
			<cfif arguments.processingTypeId == "MP">
				AND arsemlav = 'A' AND artipmat <> 'LAV'
			</cfif>

			<cfif !IsNull( arguments.str )>
				AND (
						ardesart LIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
						OR arcodart LIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
					)
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
