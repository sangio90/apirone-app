<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

		<cfargument name="locationId" required="true" type="String">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				locations
			WHERE
				location_id = <cfqueryparam value="#arguments.locationId#" cfsqltype="varchar">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query">
		<cfargument name="ids" type="Array" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				locations
			WHERE
				location_id = ANY(<cfqueryparam value="#ArrayToList( arguments.ids )#" list="false" cfsqltype="varchar">::uuid[])
		</cfquery>

		<cfreturn local.q>
	</cffunction>


	<cffunction name="find" returntype="Query">

		<cfargument name="limit" required="true" type="Numeric" default="50">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="companyId" type="String">
		<cfargument name="employeeId" type="String">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				location_id,
				COUNT(location_id) OVER() AS total
			FROM
				locations
			WHERE 1=1

			<cfif !isNull( arguments.companyId ) >
				AND company_id = <cfqueryparam value="#arguments.companyId#" cfsqltype="varchar">::uuid
			</cfif>

			<cfif !isNull( arguments.employeeId ) >
				AND employee_id = <cfqueryparam value="#arguments.employeeId#" cfsqltype="varchar">::uuid
			</cfif>

			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>

		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="insert" returntype="String">

		<cfargument name="location" type="com.apirone.core.model.bean.Location" required="true">
		<cfargument name="entity" type="com.apirone.core.model.bean.Entity" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO locations(
				address,
                city_id,
                postal_code,
                #getField( arguments.entity.getType() ).name#
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.location.getAddress()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.location.getCity().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.location.getPostalCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.entity.getId()#">::uuid
			) RETURNING location_id
		</cfquery>

		<cfreturn q.location_id.toString()>

	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="location" type="com.apirone.core.model.bean.Location" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE locations
			SET address 	= <cfqueryparam cfsqltype="Varchar" value="#arguments.location.getAddress()#">,
				city_id 	= <cfqueryparam cfsqltype="Varchar" value="#arguments.location.getCity().getId()#">::uuid,
				postal_code = <cfqueryparam cfsqltype="Varchar" value="#arguments.location.getPostalCode()#">
			WHERE
				location_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.location.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.location.getId()>

	</cffunction>


</cfcomponent>
