<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="cardId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM cards
			WHERE card_id = <cfqueryparam cfsqltype="varchar" value="#arguments.cardId#">
		</cfquery>
		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Query" name="find">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="card_id">
		<cfargument name="employeeId" type="String">    
	
        <cfquery name="local.q" datasource="apirone">
			SELECT
				card_id,
				COUNT(card_id) OVER() AS total
			FROM
				cards
			WHERE 1=1
                
				<cfif !isNull( arguments.employeeId ) >
					AND employee_id =  <cfqueryparam value="#arguments.employeeId#" cfsqltype="Varchar">::uuid
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

		<cfargument name="card" type="com.apirone.core.model.bean.Card" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO cards(
				card_id,
				emission_at,
				expiration_at,
				company_id,
				status_id,
				amount,
				email,
				phone
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.card.getId()#">,
				<cfqueryparam cfsqltype="timestamp" value="#arguments.card.getEmissionAt()#">,
				<cfqueryparam cfsqltype="timestamp" value="#arguments.card.getExpirationAt()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.card.getCompany().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.card.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Float" value="#arguments.card.getAmount()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.card.getEmail()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.card.getPhone()#">
			) 
		</cfquery>

		<cfreturn arguments.card.getId()>
	
	</cffunction>

	<cffunction name="update" returntype="String">

		<cfargument name="card" type="com.apirone.core.model.bean.Card" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE cards 
			SET 
				emission_at   = <cfqueryparam cfsqltype="timestamp" value="#arguments.card.getEmissionAt()#">,
				expiration_at = <cfqueryparam cfsqltype="timestamp" value="#arguments.card.getExpirationAt()#">,
				assigned_at   = <cfqueryparam cfsqltype="timestamp" value="#arguments.card.getAssignedAt()#">,
				employee_id   =	<cfqueryparam cfsqltype="Varchar" value="#arguments.card.getEmployeeId()#">::uuid,
				company_id	  =	<cfqueryparam cfsqltype="Varchar" value="#arguments.card.getCompany().getId()#">::uuid,
				status_id 	  = <cfqueryparam cfsqltype="Varchar" value="#arguments.card.getStatus().getId()#">,
				amount		  = <cfqueryparam cfsqltype="Float" value="#arguments.card.getAmount()#">,
				amount_spent  = <cfqueryparam cfsqltype="Float" value="#arguments.card.getAmountSpent()#">,
				email	      =	<cfqueryparam cfsqltype="Varchar" value="#arguments.card.getEmail()#">,
				phone		  =	<cfqueryparam cfsqltype="Varchar" value="#arguments.card.getPhone()#">
		</cfquery>

		<cfreturn arguments.card.getId()>
	
	</cffunction>

	<cffunction name="delete" returntype="Boolean">

		<cfargument name="cardId" type="String" required="true">
		
		<cfquery name="local.q" datasource="apirone" result="result">
			DELETE
			FROM cards
			WHERE
				card_id = <cfqueryparam cfsqltype="String" value="#arguments.cardId#">
		</cfquery>

		<cfreturn true>
	
	</cffunction>

</cfcomponent>