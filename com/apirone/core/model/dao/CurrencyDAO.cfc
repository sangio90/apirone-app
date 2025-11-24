<cfcomponent extends="com.apirone.core.model.dao.VerticaleDAO" accessors="true">

	<cffunction returntype="Query" name="read">
		<cfargument name="currencyId" type="String" required="true">

		<cfquery name="local.q" datasource="verticale">
			SELECT 
				valcod AS currency_id,
				valdes AS currency,
				valsim AS simbol
			FROM 
				codval
			WHERE
				valcod = <cfqueryparam cfsqltype="Integer" value="#arguments.currencyId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="currencyId" type="String" required="true">

		<cfquery name="local.q" datasource="verticale">
			SELECT 
				valcod AS currency_id,
				valdes AS currency,
				valsim AS simbol,
				COUNT(pagcod) OVER() AS total
			FROM 
				codval
			ORDER BY 
				valdes
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
