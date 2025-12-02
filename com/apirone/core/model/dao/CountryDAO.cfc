<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="countryId" type="String" required="true">

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