<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

		<cfargument name="rawProductId" type="String">
		<cfargument name="variantId" type="String">
		<cfargument name="colorId" type="String">

		<cfset var thisQuery = super.getQueryLoader().getCosts()>

		<cfquery name="local.q" dbtype="query">
			SELECT *
			FROM 
				thisQuery
			WHERE 1=1
				<cfif !IsNUll( arguments.rawProductId )>
					AND lisart = <cfqueryparam cfsqltype="Varchar" value="#arguments.rawProductId#">
				</cfif>
				
				<cfif !IsNUll( arguments.rawProductId )>
					AND liscvr = <cfqueryparam cfsqltype="Varchar" value="#arguments.variantId#">
				</cfif>
				
				<cfif !IsNUll( arguments.rawProductId )>
					AND liscol = <cfqueryparam cfsqltype="Varchar" value="#arguments.colorId#">
				</cfif>
			ORDER BY 
				lisart
		</cfquery>
		
		<cfreturn local.q>

	</cffunction>

</cfcomponent>