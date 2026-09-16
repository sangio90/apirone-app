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
		--->
		<cfquery name="local.q" datasource="apirone">
			SELECT
				*
			FROM verticale_countries
			WHERE
				TRIM( isonaz ) = <cfqueryparam cfsqltype="varchar" value="#Trim( arguments.countryId )#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>
