<cfcomponent extends="com.apirone.core.model.dao.VerticaleDAO" accessors="true">
	<cffunction returntype="Query" name="read">
		<cfargument name="currencyId" type="String" required="true">

		<cfif !request.loadFromVerticale>
			<cfreturn getMockedCurrency( arguments.currencyId )>
		</cfif>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				valcod AS currency_id,
				valdes AS currency,
				valsim AS simbol
			FROM
				verticale_currencies
			WHERE
				valcod = <cfqueryparam cfsqltype="varchar" value="#arguments.currencyId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">

		<cfif !request.loadFromVerticale>
			<cfreturn listMockedCurrency()>
		</cfif>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				valcod AS currency_id,
				valdes AS currency,
				valsim AS simbol,
				COUNT(valcod) OVER() AS total
			FROM
				verticale_currencies
			ORDER BY
				valdes
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
