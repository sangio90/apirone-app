<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="rolePermissionId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				*
			FROM
				membership.roles_permissions
			WHERE
				role_permission_id = <cfqueryparam cfsqltype="Integer" value="#arguments.rolePermissionId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="roleId" type="String">
		<cfargument name="permissionId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="role_permission_id desc">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				role_permission_id,
				COUNT(role_permission_id) OVER() AS total
			FROM
				membership.roles_permissions
			WHERE 1=1
				<cfif !IsNull( arguments.roleId )>
					AND role_id = <cfqueryparam value="#arguments.roleId#" cfsqltype="varchar">
				</cfif>

				<cfif !IsNull( arguments.permissionId )>
					AND permission_id = <cfqueryparam value="#arguments.permissionId#" cfsqltype="varchar">
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

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="rolePermission" type="com.apirone.core.model.bean.RolePermission" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO membership.roles_permissions (
				role_id,
				permission_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.rolePermission.getRoleId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.rolePermission.getPermission().getId()#">
			) RETURNING role_permission_id
		</cfquery>

		<cfreturn local.q.role_permission_id>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="rolePermissionId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				membership.roles_permissions
			WHERE
				role_permission_id = <cfqueryparam cfsqltype="Integer" value="#arguments.rolePermissionId#">
			RETURNING role_permission_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

</cfcomponent>
