<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="companyId" type="String" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			SELECT *
			FROM companies
			WHERE 
				company_id = <cfqueryparam cfsqltype="varchar" value="#arguments.companyId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="find">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="company">
		<cfargument name="str" type="String">    
		<cfargument name="vat" type="String">    

        <cfquery name="local.q" datasource="zerobenefit">
			SELECT
				company_id,
				COUNT(company_id) OVER() AS total
			FROM
				companies
			WHERE 1=1
                
				<cfif Len( trim( arguments.str ) )>
					AND company ILIKE <cfqueryparam value="#arguments.str#%" cfsqltype="Varchar">
				</cfif>

				<cfif !isNull( arguments.vat )>
					AND vat = <cfqueryparam value="#arguments.vat#" cfsqltype="Varchar">
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

		<cfargument name="company" type="com.apirone.core.model.bean.Company" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			INSERT INTO companies(
				company,
				types,
				vat,
				contact,
				phone,
				account_id,
				code,
				status_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.company.getName()#">,
				<cfqueryparam cfsqltype="other" value="#SerializeJSON(arguments.company.getTypesAsArray())#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.company.getVat()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.company.getContact()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.company.getPhone()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.company.getAccount().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.company.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.company.getStatus().getId()#">
			) RETURNING company_id
		</cfquery>

		<cfreturn q.company_id.toString()>
	
	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="company" type="com.apirone.core.model.bean.Company" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			UPDATE companies 
			SET 
				company = <cfqueryparam cfsqltype="Varchar" value="#arguments.company.getName()#">,
				types = <cfqueryparam cfsqltype="other" value="#serializeJSON(arguments.company.getTypesAsArray())#">,
				vat = <cfqueryparam cfsqltype="Varchar" value="#arguments.company.getVat()#">,
				contact = <cfqueryparam cfsqltype="Varchar" value="#arguments.company.getContact()#">,
				phone = <cfqueryparam cfsqltype="Varchar" value="#arguments.company.getPhone()#">,
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.company.getCode()#">,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.company.getStatus().getId()#">
			WHERE 
				company_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.company.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.company.getId()>
	
	</cffunction>

	<cffunction name="delete" returntype="Boolean">

		<cfargument name="companyId" type="String" required="true">
		<cfquery name="local.q" datasource="zerobenefit">
			DELETE
			FROM companies
			WHERE
				company_id = <cfqueryparam cfsqltype="String" value="#arguments.companyId#">::uuid
		</cfquery>

		<cfreturn true>
	
	</cffunction>

</cfcomponent>