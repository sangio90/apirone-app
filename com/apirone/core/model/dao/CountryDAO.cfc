<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="countryId" type="String" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			SELECT *
			FROM countries
			WHERE 
				country_id = <cfqueryparam cfsqltype="varchar" value="#arguments.countryId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>