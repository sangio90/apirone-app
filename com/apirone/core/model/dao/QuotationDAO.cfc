<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="quotationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotations.quotation_id::varchar,
				<!--- status_id::varchar, ---->
				lang_id::varchar,
				pricelist_id::varchar,
				payment_method_id::varchar,
				currency_id::varchar,
				billing_profile_id::varchar,
				shipping_profile_id::varchar,
				sales_agent_account_id::varchar,
				graphic_technician_account_id::varchar,
				shipping_profile_id::varchar,
				*
			FROM quotations
				INNER JOIN quotation_status_history ON quotations.quotation_status_history_id = quotation_status_history.quotation_status_history_id
			WHERE quotations.quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationId#">::uuid
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
		<cfargument name="salesAgentId" type="String" required="false">
		<cfargument name="graphicTechnicianId" type="String" required="false">
		<cfargument name="ownerId" type="String" required="false">
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
				quotations.quotation_id::varchar,
				<!--- status_id::varchar, ---->
				lang_id::varchar,
				pricelist_id::varchar,
				payment_method_id::varchar,
				currency_id::varchar,
				billing_profile_id::varchar,
				shipping_profile_id::varchar,
				sales_agent_account_id::varchar,
				graphic_technician_account_id::varchar,
				shipping_profile_id::varchar,
				COUNT( quotations.quotation_id ) OVER() AS total
			FROM quotations
				INNER JOIN quotation_status_history ON quotations.quotation_status_history_id = quotation_status_history.quotation_status_history_id
			WHERE 1=1

			<cfif !IsNull( arguments.str )>
				AND (
					quotation ILIKE <cfqueryparam cfsqltype="VARCHAR" value="%#arguments.str#%">
					OR quotation_number ILIKE <cfqueryparam cfsqltype="VARCHAR" value="%#arguments.str#%">
				)
			</cfif>

			<cfif !IsNull( arguments.statusId )>
				AND quotation_status_history.status_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.statusId#">
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

			<cfif !IsNull( arguments.salesAgentId )>
				AND sales_agent_account_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.salesAgentId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.graphicTechnicianId )>
				AND graphic_technician_account_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.graphicTechnicianId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.ownerId )>
				AND owner_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.ownerId#">::uuid
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
				note,
				validity_date,
				opportunity_id,
				lead_id,
				active,
				lang_id,
				customer_id,
				payment_method_id,
				currency_id,
				shipping_profile_id,
				sales_agent_account_id,
				graphic_technician_account_id,
				vat_code_id,
				owner_id
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getQuotationNumber()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getVersionNumber()#">,
				<cfqueryparam cfsqltype="Date" value="#arguments.quotation.getQuotationDate()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getNote()#">,
				<cfqueryparam cfsqltype="Date" value="#arguments.quotation.getValidityDate()#">,
				<cfif !IsNull( arguments.quotation.getOpportunity()?.getId() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getOpportunity().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
				,
				<cfif !IsNull( arguments.quotation.getLead()?.getId() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getLead().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
				,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getActive()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getLang().getId()#">,
				<cfif !IsNull( arguments.quotation.getCustomer()?.getId() ) >
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getCustomer().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
				,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getPaymentMethod().getId()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getCurrency().getId()#">,
				<cfif !IsNull( arguments.quotation.getShippingProfile()?.getId() ) >
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getShippingProfile().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>,
				<cfif !IsNull( arguments.quotation.getSalesAgent()?.getId() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getSalesAgent().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>,
				<cfif !IsNull( arguments.quotation.getGraphicTechnician()?.getId() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getGraphicTechnician().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>,
				<cfif !IsNull( arguments.quotation.getVatCode()?.getId() ) >
					<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getVatCode().getId()#">
				<cfelse>
					NULL
				</cfif>,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getOwner().getId()#">::uuid
			)
			RETURNING quotation_id
		</cfquery>

		<cfreturn local.q.quotation_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="quotation" type="com.apirone.core.model.bean.Quotation" required="true">

		<cfquery name="local.q" datasource="apirone" result="result">
			UPDATE quotations
			SET
				updated_at = now(),
				quotation = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getName()#">,
				quotation_date =
					<cfif !IsNull( arguments.quotation.getQuotationDate() )>
						<cfqueryparam cfsqltype="DATE" value="#arguments.quotation.getQuotationDate()#">
					<cfelse>
						NULL
					</cfif>
				,
				validity_date =
					<cfif !IsNull( arguments.quotation.getValidityDate() )>
						<cfqueryparam cfsqltype="DATE" value="#arguments.quotation.getValidityDate()#">
					<cfelse>
						NULL
					</cfif>
				,
				note = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getNote()#">,
				payment_method_id =
					<cfif !IsNull( arguments.quotation.getPaymentMethod() )>
						<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getPaymentMethod().getId()#">
					<cfelse>
						NULL
					</cfif>
				,
				currency_id =
					<cfif !IsNull( arguments.quotation.getCurrency() )>
						<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getCurrency().getId()#">
					<cfelse>
						NULL
					</cfif>
				,
				lang_id =
					<cfif !IsNull( arguments.quotation.getLang() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getLang().getId()#">
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
				shipping_profile_id =
					<cfif !IsNull( arguments.quotation.getShippingProfile() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getShippingProfile().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				opportunity_id =
					<cfif !IsNull( arguments.quotation.getOpportunity() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getOpportunity().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				lead_id =
					<cfif !IsNull( arguments.quotation.getLead() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getLead().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				sales_agent_account_id =
					<cfif !IsNull( arguments.quotation.getSalesAgent() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getSalesAgent().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				graphic_technician_account_id =
					<cfif !IsNull( arguments.quotation.getGraphicTechnician() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getGraphicTechnician().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				<cfif !IsNull( arguments.quotation.getVersionNumber() )>
					version_number = <cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getVersionNumber()#">,
				</cfif>
				vat_code_id =
					<cfif !IsNull( arguments.quotation.getVatCode() )>
						<cfqueryparam cfsqltype="Integer" value="#arguments.quotation.getVatCode().getId()#">
					<cfelse>
						NULL
					</cfif>
				,
				exported =
					<cfif !IsNull( arguments.quotation.getExported() )>
						<cfqueryparam cfsqltype="Boolean" value="#arguments.quotation.getExported()#">
					<cfelse>
						NULL
					</cfif>

			WHERE
				quotation_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotation.getId()#">::uuid
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

	<cffunction name="deleteExport" returntype="Boolean">
		<cfargument name="quotationNumber" type="String" required="true">

		<cfquery name="local.q" datasource="verticaleExport">
			DELETE FROM ORDINI_APIR
			WHERE CAST(
				LEFT(MMNUMDOC, CHARINDEX('/', MMNUMDOC + '/') - 1)
				AS INT
			) = <cfqueryparam cfsqltype="integer" value="#arguments.quotationNumber#">
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="exportProduct" returntype="Boolean">
		<cfargument name="data" type="Struct" required="true">
		<cfset var qCheck = ""/>
		<cfset var success = true/>

		<cfquery name="qCheck" datasource="verticaleExport">
			SELECT AR_CHIAVE
			FROM ARTICO_APIR
			WHERE AR_CHIAVE = '#arguments.data.AR_CHIAVE#'
		</cfquery>

		<cfif qCheck.recordCount EQ 0>
			<cfquery datasource="verticaleExport">
				INSERT INTO ARTICO_APIR (
					AR_CHIAVE, 
					ARCODART, 
					ARDESART, 
					ARDESSUP, 
					ARDATCAR, 
					ARUNMIS1, 
					VARCOD,
					VARNOT,
					CLCODICE, 
					CLANNOTA,
					AR_STATO,
					CL_STATO,
					VAR_STATO
				)
				VALUES (
					<cfqueryparam value="#arguments.data.AR_CHIAVE#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.ARCODART#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.ARDESART#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.ARDESSUP#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.ARDATCAR#" cfsqltype="date">,
					<cfqueryparam value="#arguments.data.ARUNMIS1#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.VARCOD#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.VARNOT#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.CLCODICE#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.CLANNOTA#" cfsqltype="varchar">,
					'N', <!--- nuovo ---->
					'N',
					'N' 
				)
			</cfquery>
		</cfif>

		<cfreturn success/>
	</cffunction>

	<cffunction name="exportDiba" returntype="Boolean">
		<cfargument name="data" type="Struct" required="true">
		<cfset var qCheck = ""/>
		<cfset var success = true/>
		<cfset var uniqueKey = arguments.data.DS_CHIAVE & arguments.data.CPROWNUM>

		<cfquery name="qCheck" datasource="verticaleExport">
			SELECT CONCAT(DS_CHIAVE, CPROWNUM)
			FROM DISBAS_APIR
			WHERE CONCAT(DS_CHIAVE, CPROWNUM) = '#uniqueKey#'
		</cfquery>

		<cfif qCheck.recordCount EQ 0>
			<cfquery datasource="verticaleExport">
				INSERT INTO DISBAS_APIR (
					DS_CHIAVE, 
					DSCODART, 
					DSCODVAR, 
					DSCODCOL, 
					DSCODMAT, 
					DSVARMAT, 
					DSCOLMAT, 
					DSQTAMOV, 
					DSUNMIS1, 
					CPROWNUM, 
					CPROWORD, 
					DSTIPRIG, 
					DS_STATO
				)
				VALUES (
					<cfqueryparam value="#arguments.data.DS_CHIAVE#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSCODART#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSCODVAR#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSCODCOL#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSCODMAT#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSVARMAT#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSCOLMAT#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.DSQTAMOV#" cfsqltype="numeric">,
					<cfqueryparam value="#arguments.data.DSUNMIS1#" cfsqltype="varchar">,
					<cfqueryparam value="#arguments.data.CPROWNUM#" cfsqltype="numeric">,
					<cfqueryparam value="#arguments.data.CPROWORD#" cfsqltype="numeric">,
					<cfqueryparam value="#arguments.data.DSTIPRIG#" cfsqltype="varchar">,
					'N' <!--- nuovo --->
				)
			</cfquery>
		</cfif>

		<cfreturn success/>
	</cffunction>

	<cffunction name="export" returntype="Boolean">
		<cfargument name="data" type="Struct" required="true">
		<cfset var success = true/>

		<cfquery name="agents" datasource="verticale">
			SELECT AGECOD
			FROM AZAPI_AGENTI
			WHERE
				TRIM(AGEMAI) = <cfqueryparam value="#arguments.data.MMCODAGE#" cfsqltype="varchar">
		</cfquery>

		<cfset var agentCode = 0 />

		<cfif agents.recordCount>
			<cfset agentCode = val(agents.AGECOD[1]) />
		</cfif>

		<cfquery datasource="verticaleExport">
			INSERT INTO ORDINI_APIR (
				CF_IDCLI, CFBLOCCO, CFDESCR1, CFINDIRI, CFLOCALI, CFMOROSO, CFPARIVA,
				CFPROVIN, CFSTAISO, CFTELEFO, CPROWNUM, CPROWORD, DEDESDOD, DEDESMER,
				DEIDDMER, DEINDDOD, DEINDMER, DELOCDOD, DELOCMER, DENAZDOD, DENAZMER,
				DEPRODOD, DEPROMER, MM_STATO, MMCODAGE, MMCODART, MMCODCOL, MMCODPAG,
				MMSCOCF1, MMSCOCF2, MMSPETRA, MMCODVAL, MMCODVAR, MMDATDOC, MMDATEVA, 
				MMEVASIO, MMNUMDOC, MMNUMLIS, MMQTAMOV, MMRIFORD, MMSCOAR1, MMSCOAR2, 
				MMSERIAL, MMVALUNI
			)
			VALUES (
				<cfqueryparam value="#left(arguments.data.CF_IDCLI,36)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.CFBLOCCO,1)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.CFDESCR1,40)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.CFINDIRI,35)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.CFLOCALI,30)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.CFMOROSO,1)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.CFPARIVA,11)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.CFPROVIN,2)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.CFSTAISO,3)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.CFTELEFO,18)#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.data.CPROWNUM ?: 0#" cfsqltype="integer">,
				<cfqueryparam value="#arguments.data.CPROWORD ?: 0#" cfsqltype="integer">,
				<cfqueryparam value="#left(arguments.data.DEDESDOD,35)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.DEDESMER,35)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.DEIDDMER,36)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.DEINDDOD,30)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.DEINDMER,30)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.DELOCDOD,35)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.DELOCMER,35)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.DENAZDOD,3)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.DENAZMER,3)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.DEPRODOD,2)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.DEPROMER,2)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.MM_STATO,1)#" cfsqltype="varchar">,
				<cfqueryparam value="#agentCode#" cfsqltype="integer">,
				<cfqueryparam value="#left(arguments.data.MMCODART,15)#" cfsqltype="varchar">,
				<cfqueryparam value="#left(arguments.data.MMCODCOL,6)#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.data.MMCODPAG ?: 0#" cfsqltype="integer">,
				<cfqueryparam value="#arguments.data.MMSCOCF1 ?: 0#" cfsqltype="integer">,
				<cfqueryparam value="#arguments.data.MMSCOCF2 ?: 0#" cfsqltype="integer">,
				<cfqueryparam value="#arguments.data.MMSPETRA ?: 0#" cfsqltype="integer">,
				<cfqueryparam value="#arguments.data.MMCODVAL ?: 0#" cfsqltype="integer">,
				<cfqueryparam value="#left(arguments.data.MMCODVAR,10)#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.data.MMDATDOC#" cfsqltype="date">,
				<cfqueryparam value="#arguments.data.MMDATEVA#" cfsqltype="date">,
				<cfqueryparam value="#arguments.data.MMEVASIO#" cfsqltype="date">,
				<cfqueryparam value="#left(arguments.data.MMNUMDOC,10)#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.data.MMNUMLIS ?: 1#" cfsqltype="integer">,
				<cfqueryparam value="#arguments.data.MMQTAMOV ?: 0#" cfsqltype="decimal" scale="6">,
				<cfqueryparam value="#left(arguments.data.MMRIFORD,25)#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.data.MMSCOAR1 ?: 0#" cfsqltype="decimal" scale="6">,
				<cfqueryparam value="#arguments.data.MMSCOAR2 ?: 0#" cfsqltype="decimal" scale="6">,
				<cfqueryparam value="#left(arguments.data.MMSERIAL,12)#" cfsqltype="varchar">,
				<cfqueryparam value="#arguments.data.MMVALUNI ?: 0#" cfsqltype="decimal" scale="6">
			)
		</cfquery>

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

	<cffunction name="readNextNumber" access="public" returntype="numeric">

		<cfquery name="local.q" datasource="apirone">
			SELECT nextval('quotation_number_seq');
		</cfquery>

		<cfreturn local.q.nextval>
	</cffunction>
</cfcomponent>
