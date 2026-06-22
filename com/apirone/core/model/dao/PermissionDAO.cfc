<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	
	<cffunction name="read">
		<cfargument name="permissionId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				membership.permissions
			WHERE
				permission_id = <cfqueryparam cfsqltype="varchar" value="#arguments.permissionId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="entityId" type="String">
		<cfargument name="permissionId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="permission_id">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				permission_id,
				permission,
				created_at,
				entity_id,
				COUNT(permission_id) OVER() AS total
			FROM
				membership.permissions

			WHERE 1=1

				<cfif !IsNull( arguments.entityId )>
					AND permissions.entity_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.entityId#">
				</cfif>
				
				<cfif !IsNull( arguments.permissionId )>
				AND permissions.permission_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.permissionId#">
			</cfif>
				
				<cfif !IsNull( arguments.str )>
					AND
					(
						permission_id ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
						OR permission ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
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
				membership.permissions
			WHERE
				permission_id IN ( <cfqueryparam value="#idsList#" list="true" cfsqltype="varchar"> )
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="permission" type="com.apirone.core.model.bean.Permission" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO membership.permissions (
				permission_id,
				permission
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.permission.getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.permission.getName()#">
			) RETURNING permission_id
		</cfquery>

		<cfreturn local.q.permission_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="permission" type="com.apirone.core.model.bean.Permission" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				membership.permissions
			SET
				permission = <cfqueryparam cfsqltype="Varchar" value="#arguments.permission.getName()#">
			WHERE
				permission_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.permission.getId()#">
		</cfquery>

		<cfreturn arguments.permission.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="permissionId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				membership.permissions
			WHERE
				permission_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.permissionId#">
			RETURNING permission_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

</cfcomponent>

