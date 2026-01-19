<cfcomponent extends="com.apirone.core.model.dao.VerticaleDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="countryId" type="String" required="true">

		<cfif !request.loadFromVerticale>
			<cfreturn super.getMockedCountry( arguments.countryId )>
		</cfif>

		<cfquery name="local.q" datasource="verticale">
			SELECT
				ISONAZ,
				*
			FROM CODNAZ
			WHERE 
				ISONAZ = <cfqueryparam cfsqltype="varchar" value="#arguments.countryId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>