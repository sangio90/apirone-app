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
				customer_address_id::varchar,
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
				customer_address_id::varchar,
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
				customer_id,
				customer_address_id,
				payment_method_id,
				currency_id
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
				<cfif !IsNull( arguments.quotation.getOpportunity()?.getId() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getOpportunity().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
				,
				<cfif !IsNull( arguments.quotation.getLead()?.getId() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getLead().getId()#">::uuid,
				<cfelse>
					NULL
				</cfif>
				,

				<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getActive()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getLang().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getCustomer().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getCustomerAddressId()#">::uuid,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getPaymentMethod().getId()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getCurrency().getId()#">
				<cfif true == false>
					,<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getPricelist().getId()#">::uuid,
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getCustomPaymentMethod()#">,
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
				active = <cfqueryparam cfsqltype="INTEGER" value="#arguments.quotation.getActive()#">
				,
				pricelist_id =
					<cfif !IsNull( arguments.quotation.getPricelist() )>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getPricelist().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				payment_method_id =
					<cfif !IsNull( arguments.quotation.getPaymentMethod() )>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getPaymentMethod().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				custom_payment_method =
					<cfif !IsNull( arguments.quotation.getCustomPaymentMethod() )>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getCustomPaymentMethod()#">
					<cfelse>
						NULL
					</cfif>
				,
				currency_id =
					<cfif !IsNull( arguments.quotation.getCurrency() )>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getCurrency().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				status_id =
					<cfif !IsNull( arguments.quotation.getStatus() )>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getStatus().getId()#">
					<cfelse>
						NULL
					</cfif>
				,
				lang_id =
					<cfif !IsNull( arguments.quotation.getLang() )>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getLang().getId()#">
					<cfelse>
						NULL
					</cfif>
				,
				customer_id =
					<cfif !IsNull( arguments.quotation.getCustomer() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getCustomer().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				customer_address_id =
					<cfif !IsNull( arguments.quotation.getCustomerAddressId() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getCustomerAddressId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				opportunity_id =
					<cfif !IsNull( arguments.quotation.getOpportunity() )>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getOpportunity().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				lead_id =
					<cfif !IsNull( arguments.quotation.getLead() )>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getLead().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				billing_profile_id =
					<cfif !IsNull( arguments.quotation.getBillingProfile() )>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getBillingProfile().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				shipping_profile_id =
					<cfif !IsNull( arguments.quotation.getShippingProfile() )>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getShippingProfile().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				sales_agent_account_id =
					<cfif !IsNull( arguments.quotation.getSalesAgentAccount() )>
						<cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotation.getSalesAgentAccount().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				graphic_technician_account_id =
					<cfif !IsNull( arguments.quotation.getGraphicTechnicianAccount() )>
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

	<cffunction name="export" returntype="Boolean">
		<cfargument name="data" type="Struct" required="true">
		<cfset var qCheck = ""/>
		<cfset var success = false/>

		<cfquery name="qCheck" datasource="verticaleExport">
			SELECT AR_CHIAVE
			FROM ARTICO_APIR
			WHERE AR_CHIAVE = '#arguments.data.AR_CHIAVE#'
		</cfquery>

		<cfif qCheck.recordCount EQ 0>
			<cfquery datasource="verticaleExport">
				INSERT INTO ARTICO_APIR (AR_CHIAVE, ARCODART, ARDESART, ARDATCAR, ARUNMIS1, VARCOD, CLCODICE, CLANNOTA)
				VALUES (
					<cfqueryparam value="#arguments.data.AR_CHIAVE#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.ARCODART#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.ARDESART#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.ARDATCAR#" cfsqltype="date">,
					<cfqueryparam value="#arguments.data.ARUNMIS1#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.VARCOD#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.CLCODICE#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.CLANNOTA#" cfsqltype="varchar">
				)
			</cfquery>

			<cfset success = true/>
		</cfif>

		<cfreturn success/>
	</cffunction>

	<cffunction name="exportDiba" returntype="Boolean">
		<cfargument name="data" type="Struct" required="true">
		<cfset var qCheck = ""/>
		<cfset var success = false/>
		<cfset var uniqueKey = arguments.data.DS_CHIAVE & arguments.data.CPROWNUM>

		<cfquery name="qCheck" datasource="verticaleExport">
			SELECT CONCAT(DS_CHIAVE, CPROWNUM)
			FROM DISBAS_APIR
			WHERE CONCAT(DS_CHIAVE, CPROWNUM) = '#uniqueKey#'
		</cfquery>

		<cfif qCheck.recordCount EQ 0>
			<cfquery datasource="verticaleExport">
				INSERT INTO DISBAS_APIR (DS_CHIAVE, DSCODART, DSCODVAR, DSCODCOL, DSCODMAT, DSVARMAT, DSCOLMAT, DSQTAMOV, DSUNMIS1, CPROWNUM, CPROWORD, DSTIPRIG)
				VALUES (
					<cfqueryparam value="#arguments.data.DS_CHIAVE#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSCODART#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSCODVAR#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSCODCOL#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSCODMAT#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSVARMAT#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSCOLMAT#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSQTAMOV#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSUNMIS1#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.CPROWNUM#" cfsqltype="numeric">,
					<cfqueryparam value="#arguments.data.CPROWORD#" cfsqltype="numeric">,
					<cfqueryparam value="#arguments.data.DSTIPRIG#" cfsqltype="varchar">
				)
			</cfquery>

			<cfset success = true/>
		</cfif>

		<cfreturn success/>
	</cffunction>

	<cffunction name="getQuotationTotal" access="public" returntype="numeric">
		<cfargument name="quotationId" type="String" required="true">

		<cfset var local = {}>

		<cfquery name="local.qTotal" datasource="apirone">
			SELECT
			COALESCE(SUM(price * quantity), 0) AS total_amount
			FROM quotation_items
			WHERE quotation_id = <cfqueryparam cfsqltype="varchar" value="#arguments.quotationId#">::uuid
		</cfquery>

		<cfreturn local.qTotal.total_amount>
	</cffunction>
</cfcomponent>
