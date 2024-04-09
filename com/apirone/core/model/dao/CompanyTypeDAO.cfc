<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="companyTypeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM company_types
			WHERE company_type_id = <cfqueryparam cfsqltype="varchar" value="#arguments.companyTypeId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>