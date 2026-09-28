<cfcomponent extends="com.apirone.core.model.dao.VerticaleDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="countryId" type="String" required="true">

		<cfif !request.loadFromVerticale>
			<cfreturn super.getMockedCountry( arguments.countryId )>
		</cfif>

		<!---
			isonaz porta il padding a spazi delle colonne CHAR di SQL Server (es. "IT ").
			Su SQL Server il confronto "=" era implicitamente insensibile al padding;
			su Postgres no, quindi va confrontato con TRIM() esplicito.
			Il CRM (paese degli indirizzi, assignablecountry_c) usa le sigle di Verticale
			(codnaz: UK, RSM, US...), non l'ISO: alcune righe hanno isonaz vuoto (es. UK)
			o diverso (RSM -> SM). Si cerca prima per codnaz, poi per isonaz.
		--->
		<cfquery name="local.q" datasource="apirone">
			SELECT
				*
			FROM verticale_countries
			WHERE
				TRIM( codnaz ) = <cfqueryparam cfsqltype="varchar" value="#Trim( arguments.countryId )#">
				OR TRIM( isonaz ) = <cfqueryparam cfsqltype="varchar" value="#Trim( arguments.countryId )#">
			ORDER BY
				( TRIM( codnaz ) = <cfqueryparam cfsqltype="varchar" value="#Trim( arguments.countryId )#"> ) DESC
			LIMIT 1
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>
