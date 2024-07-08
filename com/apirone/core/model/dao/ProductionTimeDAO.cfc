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


	<cffunction name="insert" returntype="String">

		<cfargument name="bean" type="com.apirone.core.model.bean.ProductionTime" required="true">

		<cfquery name="local.q" datasource="apirone">

			INSERT INTO production_times ( 
                production_time_id, 
                production_time 
            )
			VALUES ( 
                    <cfqueryparam cfsqltype="varchar" value="#arguments.bean.getId()#">,
                    <cfqueryparam cfsqltype="varchar" value="#arguments.bean.getName()#">
            )
		</cfquery>

		<cfreturn arguments.bean.getId()>

	</cffunction>


	<cffunction name="update" returntype="String">

		<cfargument name="bean" type="com.apirone.core.model.bean.ProductionTime" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE production_times 
            SET
                production_time  = <cfqueryparam cfsqltype="varchar" value="#arguments.bean.getName()#">
            WHERE
                production_time_id = <cfqueryparam cfsqltype="varchar" value="#arguments.bean.getId()#">
		</cfquery>

		<cfreturn arguments.bean.getId()>

	</cffunction>

    
	<cffunction returntype="Query" name="find">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="production_time">
		
        <cfquery name="local.q" datasource="apirone">
			SELECT
				production_time_id,
				COUNT(production_time_id) OVER() AS total
			FROM
                production_times
			WHERE 1=1
			
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