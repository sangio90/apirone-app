<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="employeeId" type="String" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			SELECT *
			FROM employees
			WHERE employee_id = <cfqueryparam cfsqltype="varchar" value="#arguments.employeeId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="find">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="surname">
		
		<cfargument name="str" type="String">    
		<cfargument name="fiscalCode" type="String">
		<cfargument name="email" type="String">
	
        <cfquery name="local.q" datasource="zerobenefit">
			SELECT
				employee_id,
				COUNT(employee_id) OVER() AS total
			FROM
				employees
			WHERE 1=1
                
				<cfif !IsNull( arguments.str )>
					AND (
						name ILIKE <cfqueryparam value="#arguments.str#%" cfsqltype="Varchar">
						OR surname ILIKE <cfqueryparam value="#arguments.str#%" cfsqltype="Varchar">
						OR email ILIKE <cfqueryparam value="#arguments.str#%" cfsqltype="Varchar">
						OR fiscalCode ILIKE <cfqueryparam value="#arguments.str#%" cfsqltype="Varchar">
					)
				</cfif>

				<cfif !IsNull( arguments.fiscalCode )>
					AND fiscal_code = <cfqueryparam value="#UCase(arguments.fiscalCode)#" cfsqltype="Varchar">
				</cfif>

				<cfif !IsNull( arguments.email )>
					AND email = <cfqueryparam value="#LCase(arguments.email)#" cfsqltype="Varchar">
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

	<cffunction name="insert" returntype="String">

		<cfargument name="employee" type="com.apirone.core.model.bean.employee" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			INSERT INTO employees(
				name,
                surname,
				fiscal_code,
				phone,
				account_id,
				status_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getSurname()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getFiscalCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getPhone()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getAccount().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getStatus().getId()#">
			) RETURNING employee_id
		</cfquery>

		<cfreturn local.q.employee_id.toString()>
	
	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="employee" type="com.apirone.core.model.bean.employee" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			UPDATE employees 
			SET 
				name = <cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getName()#">,
			    surname = <cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getSurname()#">,
				fiscal_code = <cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getFiscalCode()#">,
				phone = <cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getPhone()#">,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getStatus().getId()#">
			WHERE 
				employee_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.employee.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.employee.getId()>
	
	</cffunction>

	<cffunction name="delete" returntype="Boolean">

		<cfargument name="employeeId" type="String" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			DELETE
			FROM 
				employees
			WHERE
				employee_id = <cfqueryparam cfsqltype="String" value="#arguments.employeeId#">::uuid
		</cfquery>

		<cfreturn true>
	
	</cffunction>

</cfcomponent>