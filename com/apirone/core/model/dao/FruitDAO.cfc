<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="fruitId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT fruit_id::varchar, *
			FROM
				fruits
			WHERE
				fruit_id = <cfqueryparam cfsqltype="varchar" value="#arguments.fruitId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				fruit_id::varchar,
				*
			FROM
				fruits
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

    
	<cffunction returntype="Query" name="find">

		<cfargument name="str" type="String">
		<cfargument name="statusId" type="String">

        <cfargument name="orderby" required="true" type="String" default="code">
		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">

        <cfquery name="local.q" datasource="apirone">
			SELECT 
				fruit_id::varchar, 
				code,
				orderby,
				COUNT(fruit_id) OVER() AS total
			FROM
				fruits
			WHERE 1=1
				
				<cfif !IsNull( arguments.str )>
					AND fruits.code ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND fruits.status_id = <cfqueryparam value="#arguments.statusId#" cfsqltype="varchar">
				</cfif>

			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GTE 0>
				LIMIT 
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>

		</cfquery>

		<cfreturn local.q>

	</cffunction>	


	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="fruit" type="com.apirone.core.model.bean.Fruit" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO fruits (
				code,
				status_id,
				positions_count
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.fruit.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.fruit.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.fruit.getPositionsCount()#">
			) RETURNING fruit_id
		</cfquery>

		<cfreturn local.q.fruit_id.toString()>
	</cffunction>


	<cffunction name="update" returntype="String">
		<cfargument name="fruit" type="com.apirone.core.model.bean.Fruit" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				fruits
			SET
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.fruit.getStatus().getId()#">,
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.fruit.getCode()#">,
				positions_count = <cfqueryparam cfsqltype="Integer" value="#arguments.fruit.getPositionsCount()#">
			WHERE
				fruit_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.fruit.getId()#">::uuid
		</cfquery>
		
		<cfreturn arguments.fruit.getId()>
	
	</cffunction>

	
	<cffunction name="delete" returntype="Numeric">
		<cfargument name="fruitId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				fruits
			WHERE
				fruit_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.fruitId#">::uuid
			RETURNING fruit_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>	

</cfcomponent>