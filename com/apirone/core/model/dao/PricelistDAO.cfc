<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="pricelistId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM pricelists
			WHERE 
				pricelist_id = <cfqueryparam cfsqltype="varchar" value="#arguments.pricelistId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>