<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">
		<cfargument name="roleId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT role_id, *
			FROM
				membership.roles
			WHERE
				role_id = <cfqueryparam cfsqltype="varchar" value="#arguments.roleId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				role_id,
				COUNT(role_id) OVER() AS total
			FROM
				membership.roles
			WHERE 1=1

				<cfif !IsNull( arguments.str )>
					AND
					(
						role_id ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
						OR role ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
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

	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="role" type="com.apirone.core.model.bean.Role" required="true">

		<cfset var categories = super.getCategoriesAsArray( line.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO membership.roles (
				role_id,
				role,
				quotation_max_amount,
				quotation_max_discount
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.role.getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.role.getName()#">,
				<cfqueryparam cfsqltype="Numeric" value="#int(arguments.role.getMinQuantity())#">,
				<cfqueryparam cfsqltype="Numeric" value="#int(arguments.role.getMaxQuantity())#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.role.getQuotationMaxAmount()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.role.getQuotationMaxDiscount()#">
			) RETURNING role_id
		</cfquery>

		<cfreturn local.q.role_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="role" type="com.apirone.core.model.bean.Role" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				membership.roles
			SET
				role = <cfqueryparam cfsqltype="Varchar" value="#arguments.role.getName()#">,
				min_quantity = <cfqueryparam cfsqltype="Numeric" value="#int(arguments.role.getMinQuantity())#">,
				max_quantity = <cfqueryparam cfsqltype="Numeric" value="#int(arguments.role.getMaxQuantity())#">,
				quotation_max_amount = <cfqueryparam cfsqltype="Numeric" value="#arguments.role.getQuotationMaxAmount()#">,
				quotation_max_discount = <cfqueryparam cfsqltype="Numeric" value="#arguments.role.getQuotationMaxDiscount()#">
			WHERE
				role_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.role.getId()#">
		</cfquery>

		<cfreturn arguments.role.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="roleId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				membership.roles
			WHERE
				role_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.roleId#">
			RETURNING role_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

</cfcomponent>

