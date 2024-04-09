<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="countyId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM counties
			WHERE county_id = <cfqueryparam cfsqltype="varchar" value="#arguments.countyId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>