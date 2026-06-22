<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="productionTimeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">

			SELECT *
			FROM
				production_times
			WHERE
				production_time_id = <cfqueryparam cfsqltype="varchar" value="#arguments.productionTimeId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="str" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="production_time">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				production_time_id,
				production_time,
				status_id,
				created_at,
				COUNT(production_time_id) OVER() AS total
			FROM
				production_times
			WHERE 1=1

				<cfif !IsNull( arguments.str )>
					AND
					(
						production_times.production_time_id ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
						OR production_times.production_time ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
					)
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

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				production_times
			WHERE
				production_time_id IN ( <cfqueryparam value="#idsList#" list="true" cfsqltype="varchar"> )
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="productionTime" type="com.apirone.core.model.bean.ProductionTime" required="true">

		<cfquery name="local.q" datasource="apirone">

			INSERT INTO production_times (
				production_time_id,
				production_time,
				status_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.productionTime.getId()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.productionTime.getName()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.productionTime.getStatus().getId()#">
			)
		</cfquery>

		<cfreturn arguments.productionTime.getId()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="productionTime" type="com.apirone.core.model.bean.ProductionTime" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE production_times
			SET
				production_time  = <cfqueryparam cfsqltype="varchar" value="#arguments.productionTime.getName()#">,
				status_id  = <cfqueryparam cfsqltype="varchar" value="#arguments.productionTime.getStatus().getId()#">
			WHERE
				production_time_id = <cfqueryparam cfsqltype="varchar" value="#arguments.productionTime.getId()#">
		</cfquery>

		<cfreturn arguments.productionTime.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="productionTimeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				production_times
			WHERE
				production_time_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productionTimeId#">
			RETURNING production_time_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
