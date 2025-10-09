<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="rawProductId" type="String">
		<cfargument name="variantId" type="String">
		<cfargument name="colorId" type="String">

		<cfset var thisQuery = super.getQueryLoader().getCosts()>

		<!--- NOTE: This is a QoQ, I need to trim the value to the left. --->

		<cfquery name="local.q" dbtype="query" datasource="verticale">
			SELECT *
			FROM
				thisQuery
			WHERE 1=1
				<cfif !IsNull( arguments.rawProductId )>
					AND TRIM( lisart ) = <cfqueryparam cfsqltype="Varchar" value="#arguments.rawProductId#">
				</cfif>

				<cfif !IsNull( arguments.variantId )>
					AND TRIM( liscvr ) = <cfqueryparam cfsqltype="Varchar" value="#arguments.variantId#">
				</cfif>

				<cfif !IsNull( arguments.colorId )>
					AND TRIM( liscol ) = <cfqueryparam cfsqltype="Varchar" value="#arguments.colorId#">
				</cfif>
			ORDER BY
				lisart
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
