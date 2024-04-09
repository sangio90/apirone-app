<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="cityId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM cities
			WHERE city_id = <cfqueryparam cfsqltype="varchar" value="#arguments.cityId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="find">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="city">
		<cfargument name="str" type="String">
		<cfargument name="countryId" type="String">
		<cfargument name="stateId" type="String">
		<cfargument name="countyId" type="String">

		<cfquery name="local.q" datasource="apirone">
			SELECT 	city_id,
					COUNT(city_id) OVER() AS total
			FROM cities
				INNER JOIN public.counties USING (county_id)
					INNER JOIN public.states USING (state_id)
						INNER JOIN public.countries USING (country_id)
			WHERE 1=1

			<cfif !isNull( arguments.countryId ) >
				AND country_id = <cfqueryparam cfsqltype="varchar" value="#arguments.countryId#">::uuid
			</cfif>

			<cfif !isNull( arguments.stateId ) >
				AND state_id = <cfqueryparam cfsqltype="varchar" value="#arguments.stateId#">::uuid
			</cfif>

			<cfif !isNull( arguments.countyId ) >
				AND county_id = <cfqueryparam cfsqltype="varchar" value="#arguments.countyId#">
			</cfif>

			<cfif !isNull( arguments.str ) >
				AND city ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.str#%">
			</cfif>

			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				LIMIT  
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET 
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>


</cfcomponent>