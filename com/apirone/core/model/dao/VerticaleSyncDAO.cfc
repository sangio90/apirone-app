<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<!---
		Lock/stato sincronizzazione: riga singola (id = 1) in verticale_sync_status.
		tryAcquireLock() è l'UPDATE atomico che impedisce a due lanci concorrenti di partire insieme.
	--->

	<cffunction name="tryAcquireLock" access="public" returntype="Boolean">
		<!--- userId vuoto = lancio non riconducibile a un utente (es. schedulazione automatica): started_by_user_id resta NULL. --->
		<cfargument name="userId" type="String" required="false" default="">

		<cfquery name="local.q" datasource="apirone" result="local.result">
			UPDATE verticale_sync_status
			SET
				running = true,
				started_at = (now() AT TIME ZONE 'UTC'),
				started_by_user_id = <cfqueryparam cfsqltype="varchar" value="#arguments.userId#" null="#!Len( arguments.userId )#">::uuid,
				last_error = NULL
			WHERE
				id = 1
				AND running = false
		</cfquery>

		<cfreturn local.result.recordCount GT 0>
	</cffunction>

	<cffunction name="releaseLock" access="public" returntype="void">
		<cfargument name="succeeded" type="Boolean" required="true">
		<cfargument name="errorMessage" type="String" required="false" default="">

		<cfif arguments.succeeded>
			<cfquery datasource="apirone">
				UPDATE verticale_sync_status
				SET
					running = false,
					finished_at = (now() AT TIME ZONE 'UTC'),
					last_error = NULL
				WHERE
					id = 1
			</cfquery>
		<cfelse>
			<cfquery datasource="apirone">
				UPDATE verticale_sync_status
				SET
					running = false,
					last_error = <cfqueryparam cfsqltype="varchar" value="#Left( arguments.errorMessage, 4000 )#">
				WHERE
					id = 1
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="getStatus" access="public" returntype="Query">
		<cfquery name="local.q" datasource="apirone">
			SELECT running, finished_at
			FROM verticale_sync_status
			WHERE id = 1
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Un metodo syncX() per dominio: legge dal vivo da Verticale e sostituisce
		per intero la tabella locale corrispondente. Ogni metodo è pensato per essere
		chiamato dentro un proprio try/catch dal chiamante (VerticaleSyncService),
		così un dominio che fallisce non blocca gli altri.
	--->

	<cffunction name="syncPriceList" access="public" returntype="void">
		<cfquery name="local.q" datasource="verticale">
			SELECT lisart, liscvr, liscol, lispre
			FROM azapi_listin
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_price_list",
			columns = [
				{ name = "lisart", cfsqltype = "varchar" },
				{ name = "liscvr", cfsqltype = "varchar" },
				{ name = "liscol", cfsqltype = "varchar" },
				{ name = "lispre", cfsqltype = "decimal" }
			],
			sourceQuery = local.q
		)>
	</cffunction>

	<cffunction name="syncRawProducts" access="public" returntype="void">
		<cfquery name="local.q" datasource="verticale">
			SELECT
				arcodart, ardesart, artipmat, arsemlav, arunmis1, artipcol, arobsole
			FROM azapi_artico
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_raw_products",
			columns = [
				{ name = "arcodart", cfsqltype = "varchar" },
				{ name = "ardesart", cfsqltype = "varchar" },
				{ name = "artipmat", cfsqltype = "varchar" },
				{ name = "arsemlav", cfsqltype = "varchar" },
				{ name = "arunmis1", cfsqltype = "varchar" },
				{ name = "artipcol", cfsqltype = "varchar" },
				{ name = "arobsole", cfsqltype = "varchar" }
			],
			sourceQuery = local.q
		)>
	</cffunction>

	<cffunction name="syncRawProductTypes" access="public" returntype="void">
		<cfquery name="local.q" datasource="verticale">
			SELECT codtip, destip
			FROM azapi_codtip
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_raw_product_types",
			columns = [
				{ name = "codtip", cfsqltype = "varchar" },
				{ name = "destip", cfsqltype = "varchar" }
			],
			sourceQuery = local.q
		)>
	</cffunction>

	<cffunction name="syncVariants" access="public" returntype="void">
		<cfquery name="local.variants" datasource="verticale">
			SELECT varcod, vardes
			FROM azapi_codvar
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_variants",
			columns = [
				{ name = "varcod", cfsqltype = "varchar" },
				{ name = "vardes", cfsqltype = "varchar" }
			],
			sourceQuery = local.variants
		)>

		<cfquery name="local.variantProducts" datasource="verticale">
			SELECT cbcodart, cbcodvar
			FROM azapi_comvar
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_variant_products",
			columns = [
				{ name = "cbcodart", cfsqltype = "varchar" },
				{ name = "cbcodvar", cfsqltype = "varchar" }
			],
			sourceQuery = local.variantProducts
		)>
	</cffunction>

	<cffunction name="syncColors" access="public" returntype="void">
		<cfquery name="local.colors" datasource="verticale">
			SELECT clcodice, cldescri
			FROM azapi_colori
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_colors",
			columns = [
				{ name = "clcodice", cfsqltype = "varchar" },
				{ name = "cldescri", cfsqltype = "varchar" }
			],
			sourceQuery = local.colors
		)>

		<cfquery name="local.colorProducts" datasource="verticale">
			SELECT clcodart, clcodcol
			FROM azapi_comcol
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_color_products",
			columns = [
				{ name = "clcodart", cfsqltype = "varchar" },
				{ name = "clcodcol", cfsqltype = "varchar" }
			],
			sourceQuery = local.colorProducts
		)>

		<cfquery name="local.colorVariantProducts" datasource="verticale">
			SELECT clcodart, clcodvar, clcodcol
			FROM azapi_cvrcom
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_color_variant_products",
			columns = [
				{ name = "clcodart", cfsqltype = "varchar" },
				{ name = "clcodvar", cfsqltype = "varchar" },
				{ name = "clcodcol", cfsqltype = "varchar" }
			],
			sourceQuery = local.colorVariantProducts
		)>
	</cffunction>

	<cffunction name="syncCurrencies" access="public" returntype="void">
		<cfquery name="local.q" datasource="verticale">
			SELECT
				valcod AS valcod,
				valdes AS valdes,
				valsim AS valsim
			FROM codval
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_currencies",
			columns = [
				{ name = "valcod", cfsqltype = "varchar" },
				{ name = "valdes", cfsqltype = "varchar" },
				{ name = "valsim", cfsqltype = "varchar" }
			],
			sourceQuery = local.q
		)>
	</cffunction>

	<cffunction name="syncVatCodes" access="public" returntype="void">
		<cfquery name="local.q" datasource="verticale">
			SELECT ivacod, ivades, ivaper
			FROM codiva
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_vat_codes",
			columns = [
				{ name = "ivacod", cfsqltype = "varchar" },
				{ name = "ivades", cfsqltype = "varchar" },
				{ name = "ivaper", cfsqltype = "decimal" }
			],
			sourceQuery = local.q
		)>
	</cffunction>

	<cffunction name="syncPaymentMethods" access="public" returntype="void">
		<cfquery name="local.q" datasource="verticale">
			SELECT pagcod, pagdes
			FROM codpag
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_payment_methods",
			columns = [
				{ name = "pagcod", cfsqltype = "varchar" },
				{ name = "pagdes", cfsqltype = "varchar" }
			],
			sourceQuery = local.q
		)>
	</cffunction>

	<cffunction name="syncCountries" access="public" returntype="void">
		<cfquery name="local.q" datasource="verticale">
			SELECT ISONAZ AS isonaz, CODNAZ AS codnaz, DESNAZ AS desnaz
			FROM codnaz
		</cfquery>

		<cfset replaceLocalTable(
			tableName = "verticale_countries",
			columns = [
				{ name = "isonaz", cfsqltype = "varchar" },
				{ name = "codnaz", cfsqltype = "varchar" },
				{ name = "desnaz", cfsqltype = "varchar" }
			],
			sourceQuery = local.q
		)>
	</cffunction>

	<!---
		private methods
	--->

	<!---
		Svuota e ripopola una tabella locale (datasource apirone) a partire da una Query
		già letta da Verticale, dentro un'unica transazione (nessuna finestra con la
		tabella vuota se non in caso di errore, che fa comunque rollback del DELETE).
		Insert a blocchi da 500 righe per non generare un singolo statement enorme.
	--->
	<cffunction name="replaceLocalTable" access="private" returntype="void">
		<cfargument name="tableName" type="String" required="true">
		<cfargument name="columns" type="Array" required="true">
		<cfargument name="sourceQuery" type="Query" required="true">

		<cfset var safeTableName = sanitizeSQL( arguments.tableName )>
		<cfset var columnNames = []>
		<cfloop array="#arguments.columns#" index="col">
			<cfset ArrayAppend( columnNames, sanitizeSQL( col.name ) )>
		</cfloop>

		<cfset var batchSize = 500>
		<cfset var totalRows = arguments.sourceQuery.recordCount>

		<cftransaction>

			<cfquery datasource="apirone">
				DELETE FROM #safeTableName#
			</cfquery>

			<cfset var start = 1>
			<cfloop condition="start LTE totalRows">
				<cfset var thisEnd = Min( start + batchSize - 1, totalRows )>

				<cfquery datasource="apirone">
					INSERT INTO #safeTableName# ( #ArrayToList( columnNames )# )
					VALUES
					<cfloop from="#start#" to="#thisEnd#" index="rowIndex">
						<cfif rowIndex GT start>,</cfif>
						(
							<cfloop from="1" to="#ArrayLen( arguments.columns )#" index="colIndex">
								<cfif colIndex GT 1>,</cfif>
								<cfset var colDef = arguments.columns[ colIndex ]>
								<cfset var cellValue = arguments.sourceQuery[ colDef.name ][ rowIndex ]>
								<cfqueryparam
									value="#cellValue#"
									cfsqltype="#colDef.cfsqltype#"
									null="#( colDef.cfsqltype IS "decimal" AND !Len( Trim( cellValue ) ) )#">
							</cfloop>
						)
					</cfloop>
				</cfquery>

				<cfset start = thisEnd + 1>
			</cfloop>

		</cftransaction>
	</cffunction>

</cfcomponent>
