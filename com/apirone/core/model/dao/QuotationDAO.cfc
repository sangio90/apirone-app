<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_id::varchar,
				status_id::varchar,
				lang_id::varchar,
				pricelist_id::varchar,
				payment_method_id::varchar,
				currency_id::varchar,
				billing_profile_id::varchar,
				shipping_profile_id::varchar,
				sales_agent_account_id::varchar,
				graphic_technician_account_id::varchar,
				*
			FROM quotations
			WHERE quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="statusId" type="String" required="false">
		<cfargument name="langId" type="String" required="false">
		<cfargument name="pricelistId" type="String" required="false">
		<cfargument name="paymentMethodId" type="String" required="false">
		<cfargument name="currencyId" type="String" required="false">
		<cfargument name="billingProfileId" type="String" required="false">
		<cfargument name="shippingProfileId" type="String" required="false">
		<cfargument name="salesAgentAccountId" type="String" required="false">
		<cfargument name="graphicTechnicianAccountId" type="String" required="false">
		<cfargument name="str" type="String" required="false">

		<cfargument
			name    ="orderBy"
			type    ="String"
			required="true"
			default ="quotations.quotation_date, quotations.quotation_number"
		>

		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_id::varchar,
				status_id::varchar,
				lang_id::varchar,
				pricelist_id::varchar,
				payment_method_id::varchar,
				currency_id::varchar,
				billing_profile_id::varchar,
				shipping_profile_id::varchar,
				sales_agent_account_id::varchar,
				graphic_technician_account_id::varchar,
				COUNT( quotation_id ) OVER() AS total
			FROM quotations
			WHERE 1=1

			<cfif !IsNull( arguments.str )>
				AND (
					quotation ILIKE <cfqueryparam cfsqltype="VARCHAR" value="%#arguments.str#%">
					OR quotation_number ILIKE <cfqueryparam cfsqltype="VARCHAR" value="%#arguments.str#%">
				)
			</cfif>

			<cfif !IsNull( arguments.statusId )>
				AND status_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.statusId#">
			</cfif>

			<cfif !IsNull( arguments.langId )>
				AND lang_id = <cfqueryparam cfsqltype="CHAR" value="#arguments.langId#">
			</cfif>

			<cfif !IsNull( arguments.pricelistId )>
				AND pricelist_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.pricelistId#">
			</cfif>

			<cfif !IsNull( arguments.paymentMethodId )>
				AND payment_method_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.paymentMethodId#">
			</cfif>

			<cfif !IsNull( arguments.currencyId )>
				AND currency_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.currencyId#">
			</cfif>

			<cfif !IsNull( arguments.billingProfileId )>
				AND billing_profile_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.billingProfileId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.shippingProfileId )>
				AND shipping_profile_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.shippingProfileId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.salesAgentAccountId )>
				AND sales_agent_account_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.salesAgentAccountId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.graphicTechnicianAccountId )>
				AND graphic_technician_account_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.graphicTechnicianAccountId#">::uuid
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
		<cfargument name="quotation" type="com.apirone.core.model.bean.Quotation" required="true">
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotations (
				quotation,
				quotation_number,
				version_number,
				quotation_date,
				notes,
				validity_date,
				opportunity_id,
				lead_id,
				active,
				status_id,
				lang_id,
				customer_id
				<cfif true == false>
					,pricelist_id,
					payment_method_id,
					custom_payment_method,
					currency_id,
					billing_profile_id,
					shipping_profile_id,
					sales_agent_account_id,
					graphic_technician_account_id
				</cfif>
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getQuotationNumber()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getVersionNumber()#">,
				<cfqueryparam cfsqltype="Date" value="#arguments.quotation.getQuotationDate()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getNotes()#">,
				<cfqueryparam cfsqltype="Date" value="#arguments.quotation.getValidityDate()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getOpportunityId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getLeadId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getActive()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getLang().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getCustomerId()#">::uuid
				<cfif true == false>
					,<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getPricelist().getId()#">::uuid,
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getPaymentMethod().getId()#">::uuid,
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getCustomPaymentMethod()#">,
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getCurrency().getId()#">::uuid,
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getBillingProfile().getId()#">::uuid,
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getShippingProfile().getId()#">::uuid,
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getSalesAgentAccount().getId()#">::uuid,
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getGraphicTechnicianAccount().getId()#">::uuid
				</cfif>
			)
			RETURNING quotation_id
		</cfquery>

		<cfreturn local.q.quotation_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="quotation" type="com.apirone.core.model.bean.Quotation" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE quotations
			SET
				quotation = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getName()#">
				,
				quotation_number = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getQuotationNumber()#">
				,
				version_number = <cfqueryparam cfsqltype="INTEGER" value="#arguments.quotation.getVersionNumber()#">
				,
				quotation_date = <cfqueryparam cfsqltype="DATE" value="#arguments.quotation.getQuotationDate()#">
				,
				notes = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getNotes()#">
				,
				validity_date = <cfqueryparam cfsqltype="DATE" value="#arguments.quotation.getValidityDate()#">
				,
				opportunity_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getOpportunityId()#">::uuid
				,
				lead_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getLeadId()#">::uuid
				,
				active = <cfqueryparam cfsqltype="INTEGER" value="#arguments.quotation.getActive()#">
				,
				pricelist_id = 
					<cfif !isNull(arguments.quotation.getPricelist())>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getPricelist().getId()#">::uuid 
					<cfelse> 
						NULL 
					</cfif>
				,
				payment_method_id = 
					<cfif !isNull(arguments.quotation.getPaymentMethod())>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getPaymentMethod().getId()#">::uuid
					<cfelse> 
						NULL 
					</cfif>
				,
				custom_payment_method = 
					<cfif !isNull(arguments.quotation.getCustomPaymentMethod())>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getCustomPaymentMethod()#">
					<cfelse> 
						NULL 
					</cfif>
				,
				currency_id = 
					<cfif !isNull(arguments.quotation.getCurrency())>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getCurrency().getId()#">::uuid
					<cfelse> 
						NULL 
					</cfif>
				,
				status_id = 
					<cfif !isNull(arguments.quotation.getStatus())>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getStatus().getId()#">
					<cfelse> 
						NULL 
					</cfif>
				,
				lang_id = 
					<cfif !isNull(arguments.quotation.getLang())>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getLang().getId()#">
					<cfelse> 
						NULL 
					</cfif>
				,
				customer_id = 
					<cfif !isNull(arguments.quotation.getCustomerId())>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getCustomerId()#">::uuid
					<cfelse> 
						NULL 
					</cfif>
				,
				billing_profile_id = 
					<cfif !isNull(arguments.quotation.getBillingProfile())>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getBillingProfile().getId()#">::uuid
					<cfelse> 
						NULL 
					</cfif>
				,
				shipping_profile_id = 
					<cfif !isNull(arguments.quotation.getShippingProfile())>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getShippingProfile().getId()#">::uuid
					<cfelse> 
						NULL 
					</cfif>
				,
				sales_agent_account_id = 
					<cfif !isNull(arguments.quotation.getSalesAgentAccount())>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getSalesAgentAccount().getId()#">::uuid
					<cfelse> 
						NULL 
					</cfif>
				,
				graphic_technician_account_id = 
					<cfif !isNull(arguments.quotation.getGraphicTechnicianAccount())>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getGraphicTechnicianAccount().getId()#">::uuid
					<cfelse> 
						NULL 
					</cfif>

			WHERE
				quotation_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.quotation.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="quotationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM quotations
			WHERE quotation_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationId#">::uuid
		</cfquery>

		<cfreturn true>
	</cffunction>
</cfcomponent>
