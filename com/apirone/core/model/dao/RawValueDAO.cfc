<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="rawValueId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				raw_values
			WHERE
				raw_value_id = <cfqueryparam cfsqltype="Integer" value="#arguments.rawValueId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				raw_value_id, 
				code
			FROM
				raw_values
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String">
		<cfargument name="statusId" type="String">
		
		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">

        <cfquery name="local.q" datasource="apirone">
			SELECT DISTINCT
				code, 
				raw_value_id,
				<!---- COUNT(raw_value_id) AS total ---->
				COUNT(raw_value_id) OVER() AS total
			FROM
                raw_values
					<cfif !IsNull( arguments.str )>
						INNER JOIN texts USING ( raw_value_id )
					</cfif>
			WHERE 1=1
				<cfif !IsNull( arguments.str )>
					AND
						( 
						texts.text ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
						OR
						raw_values.code ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
						)
				</cfif>
				
				<cfif !IsNull( arguments.statusId )>
					AND raw_values.status_id = <cfqueryparam cfsqltype="varchar" value="#arguments.statusId#">
				</cfif>

			GROUP BY 
				code, 
				raw_value_id
			ORDER BY
				code ASC, 
				raw_value_id 
			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="insert" returntype="Numeric">

		<cfargument name="value" type="com.apirone.core.model.bean.RawValue" required="true">

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO raw_values (
				status_id,
				code
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.value.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.value.getCode()#">
			) RETURNING raw_value_id
		</cfquery>

		<cfreturn local.q.raw_value_id>

	</cffunction>


	<cffunction name="update" returntype="Numeric">

		<cfargument name="value" type="com.apirone.core.model.bean.RawValue" required="true">

        <cfquery name="local.q" datasource="apirone">
			UPDATE raw_values 
			SET
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.value.getStatus().getId()#">,
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.value.getCode()#">
			WHERE
				raw_value_id = <cfqueryparam cfsqltype="Integer" value="#arguments.value.getId()#">
		</cfquery>

		<cfreturn arguments.value.getId()>

	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		
		<cfargument name="rawValueId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				raw_values
			WHERE
				raw_value_id = <cfqueryparam cfsqltype="Integer" value="#arguments.rawValueId#">
			RETURNING raw_value_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

</cfcomponent>