<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="componentId" type="Numeric" required="true">
		<cfargument name="productItemId" type="Numeric" required="false">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				components
			WHERE
				component_id = <cfqueryparam cfsqltype="Integer" value="#arguments.componentId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>
	
	<cffunction name="priceCalculatorRead" returntype="struct">
		<cfargument name="componentId" type="numeric" required="false">
		<cfargument name="productItemId" type="numeric" required="false">

		<!--- Le espressioni CASE isDeleted/totalQuantity sono replicate in priceCalculatorReadByProductItemIds(): tenere sincronizzate. --->
		<cfquery name="componentQuery" datasource="apirone">
			SELECT
				c.component_id as id,
				
				CASE 
					WHEN co.deleted = true THEN true
					ELSE false
				END AS isDeleted,

				CASE
					WHEN co.deleted = true THEN 0
					WHEN co.quantity IS NOT NULL THEN c.quantity + co.quantity
					ELSE c.quantity
				END AS totalQuantity,

				c.raw_product_id,
				c.variant_id,
				c.color_id

			FROM components c

			LEFT JOIN component_overrides co 
				ON c.component_id = co.component_id 
				<cfif NOT IsNull(arguments.productItemId)>
					AND co.product_item_id = <cfqueryparam value="#arguments.productItemId#" cfsqltype="integer">
				</cfif>
			WHERE 1=1
			<cfif NOT IsNull(arguments.componentId)>
				AND c.component_id = <cfqueryparam value="#arguments.componentId#" cfsqltype="integer">
			</cfif>
			<cfif NOT IsNull(arguments.productItemId)>
				AND c.product_item_id = <cfqueryparam value="#arguments.productItemId#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfif componentQuery.recordCount EQ 0>
			<cfreturn {} />
		</cfif>

		<cfset component = componentQuery.getRow(1)>
		<cfset component["costAmount"] = getComponentCost(
			rawProductId = component.raw_product_id,
			variantId    = component.variant_id,
			colorId      = component.color_id
		)>

		<cfset var rawProduct = getRawProductData( component.raw_product_id )>
		<cfset component["raw_product_name"] = rawProduct.raw_product_name>
		<cfset component["raw_product_processiong_type"] = rawProduct.raw_product_processiong_type>

		<cfreturn component>
	</cffunction>

	<!---
		Recupera il costo (lispre) della materia prima dal gestionale verticale.
		Estratto da priceCalculatorRead() per essere riutilizzato dal path batch
		(priceCalculatorSearchByProductItemIds in ComponentService).
	--->
	<cffunction name="getComponentCost" returntype="any" access="public">
		<cfargument name="rawProductId" required="true">
		<cfargument name="variantId" required="true">
		<cfargument name="colorId" required="true">

		<cfquery name="verticalCost" datasource="verticale">
			SELECT TOP 1 lispre
			FROM azapi_listin
			WHERE TRIM(lisart) = <cfqueryparam value="#Trim(arguments.rawProductId)#" cfsqltype="varchar">
			AND (
				(
					TRIM(liscvr) = <cfqueryparam value="#Trim(arguments.variantId)#" cfsqltype="varchar"> AND 
					TRIM(liscol) = <cfqueryparam value="#Trim(arguments.colorId)#" cfsqltype="varchar">
				) 
				OR TRIM(liscvr) = <cfqueryparam value="#Trim(arguments.variantId)#" cfsqltype="varchar">
				OR TRIM(liscol) = <cfqueryparam value="#Trim(arguments.colorId)#" cfsqltype="varchar">
				OR 1=1
			)
			ORDER BY
				CASE
					WHEN 
						TRIM(liscvr) = <cfqueryparam value="#Trim(arguments.variantId)#" cfsqltype="varchar">
						AND TRIM(liscol) = <cfqueryparam value="#Trim(arguments.colorId)#" cfsqltype="varchar"> 
						THEN 1
					WHEN 
						TRIM(liscvr) = <cfqueryparam value="#Trim(arguments.variantId)#" cfsqltype="varchar"> 
						THEN 2
					WHEN 
						TRIM(liscol) = <cfqueryparam value="#Trim(arguments.colorId)#" cfsqltype="varchar"> 
						THEN 3
					ELSE 4
				END
		</cfquery>

		<cfif verticalCost.recordCount GT 0>
			<cfreturn verticalCost.lispre[1]>
		</cfif>

		<cfreturn 0>
	</cffunction>

	<!---
		Recupera nome e tipo di lavorazione della materia prima dal gestionale verticale.
		Estratto da priceCalculatorRead() per essere riutilizzato dal path batch.
	--->
	<cffunction name="getRawProductData" returntype="Struct" access="public">
		<cfargument name="rawProductId" required="true">

		<cfquery name="rawProductData" datasource="verticale">
			SELECT
				ardesart as raw_product_name,
				CASE WHEN artipmat = 'LAV' THEN 'LV' ELSE 'MP' END AS raw_product_processiong_type
			FROM
				azapi_artico a
			WHERE
				arcodart = <cfqueryparam cfsqltype="varchar" value="#arguments.rawProductId#">
		</cfquery>

		<cfif rawProductData.recordCount GT 0>
			<cfreturn {
				"raw_product_name"              = rawProductData.getRow(1).raw_product_name,
				"raw_product_processiong_type"  = rawProductData.getRow(1).raw_product_processiong_type
			}>
		</cfif>

		<cfreturn { "raw_product_name" = "", "raw_product_processiong_type" = "" }>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="lineId" type="String">
		<cfargument name="modelId" type="String">
		<cfargument name="productId" type="String">
		<cfargument name="productItemId" type="Numeric">
		<cfargument name="attributeValueId" type="String">
		<cfargument name="rawProductId" type="String">
		<cfargument name="variantId" type="String">
		<cfargument name="colorId" type="String">
		<cfargument name="signageConfigItemId" type="String">

		<cfargument name="signageItemProduct" type="Struct">
		<!--- productItemId AND SignageConfigItemId --->

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="created_at desc">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				component_id,
				COUNT(component_id) OVER() AS total
			FROM
				components
			WHERE 1=1

				<cfif !IsNull( arguments.signageItemProduct )>
					AND product_item_join_id = <cfqueryparam value="#arguments.signageItemProduct.productItemId#" cfsqltype="Integer">
					AND signage_config_item_join_id = <cfqueryparam value="#arguments.signageItemProduct.SignageConfigItemId#" cfsqltype="Integer">
				</cfif>

				<cfif !IsNull( arguments.productItemId )>
					AND product_item_id = <cfqueryparam value="#arguments.productItemId#" cfsqltype="Integer">
				</cfif>

				<cfif !IsNull( arguments.productId )>
					AND product_id = <cfqueryparam value="#arguments.productId#" cfsqltype="Varchar">::uuid
				</cfif>

				<cfif !IsNull( arguments.lineId )>
					AND line_id = <cfqueryparam value="#arguments.lineId#" cfsqltype="Varchar">::uuid
				</cfif>

				<cfif !IsNull( arguments.modelId )>
					AND model_id = <cfqueryparam value="#arguments.modelId#" cfsqltype="Varchar">::uuid
				</cfif>

				<cfif !IsNull( arguments.attributeValueId )>
					AND attribute_raw_value_id = <cfqueryparam value="#arguments.attributeValueId#" cfsqltype="Integer">
				</cfif>

				<cfif !IsNull( arguments.rawProductId )>
					AND TRIM(raw_product_id) = <cfqueryparam value="#arguments.rawProductId#" cfsqltype="Varchar">
				</cfif>

				<cfif !IsNull( arguments.variantId )>
					AND TRIM(variant_id) = <cfqueryparam value="#arguments.variantId#" cfsqltype="Varchar">
				</cfif>

				<cfif !IsNull( arguments.colorId )>
					AND TRIM(color_id) = <cfqueryparam value="#arguments.colorId#" cfsqltype="Varchar">
				</cfif>

				<cfif !IsNull( arguments.signageConfigItemId )>
					AND signage_config_item_id = <cfqueryparam value="#arguments.signageConfigItemId#" cfsqltype="Integer">
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="componentId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone" result="result">
			DELETE FROM
				components
			WHERE
				component_id = <cfqueryparam cfsqltype="Integer" value="#arguments.componentId#">
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="deleteByParams" returntype="Boolean">
		<cfargument name="component" type="com.apirone.core.model.bean.Component" required="true">

		<cfset var meta = getFieldsAndValues( arguments.component )>

		<cfquery name="local.q" datasource="apirone" result="result">
			DELETE FROM components
			WHERE
				component_id = <cfqueryparam cfsqltype="Integer" value="#arguments.component.getId()#">

				<cfloop array="#meta.fields#" index="index" item="field">
					AND #field# = <cfif meta.values[ index ].type IS "uuid">
						<cfqueryparam cfsqltype="Varchar" value="#meta.values[ index ].value#">::uuid
					<cfelse>
						<cfqueryparam cfsqltype="#meta.values[ index ].type#" value="#meta.values[ index ].value#">
					</cfif>
				</cfloop>
		</cfquery>

		<cfreturn true>
	</cffunction>

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="component" type="com.apirone.core.model.bean.Component" required="true">

		<cfset var meta = getFieldsAndValues( arguments.component )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO components (
				raw_product_id,
				color_id,
				variant_id,
				quantity,

				#ArrayToList( meta.fields )#

			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.component.getRawProduct().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.component.getColor().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.component.getVariant().getId()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.component.getQuantity()#">,

				<cfloop array="#meta.values#" item="item" index="index">
					<cfif item.type IS "uuid">
						<cfqueryparam cfsqltype="Varchar" value="#item.value#">::uuid
					<cfelse>
						<cfqueryparam cfsqltype="#item.type#" value="#item.value#">
					</cfif>
					<cfif Len( meta.values ) NEQ index>
						,
					</cfif>
				</cfloop>

			) RETURNING component_id
		</cfquery>

		<cfreturn local.q.component_id>
	</cffunction>

	<cffunction name="update" returntype="Numeric">
		<cfargument name="component" type="com.apirone.core.model.bean.Component" required="true">

		<!--- <cfset var meta = getFieldsAndValues( arguments.component )> --->

		<cfquery name="local.q" datasource="apirone">
			UPDATE components
			SET
				quantity = <cfqueryparam cfsqltype="Numeric" value="#arguments.component.getQuantity()#">
			WHERE
				component_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.component.getId()#">
		</cfquery>

		<cffile action="APPEND" file="#ExpandPath( "/debug.log" )#" output="#Now()# ComponentDAO: update">

		<cfreturn arguments.component.getId()>
	</cffunction>

	<cffunction name="reassign" returntype="Numeric">
		<cfargument name="componentId" type="Numeric" required="true">
		<cfargument name="paramCategory" type="String">
		<cfargument name="newParam" type="String" required="true">

		<cfset var dbField = getDBField( "component.#arguments.paramCategory#" )>

		<cfquery name="local.q" datasource="apirone">
			UPDATE components
			SET #dbField.name# = <cfqueryparam cfsqltype="Varchar" value="#arguments.newParam#">
			WHERE
				component_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.componentId#">
		</cfquery>
		<cfreturn arguments.componentId>
	</cffunction>

	<!--- private methods --->

	<cffunction name="getFieldsAndValues" returntype="Struct" access="private">
		<cfargument name="component" type="com.apirone.core.model.bean.Component" required="true">

		<cfset var meta = GetMetadata( arguments.component )>

		<cfset var field = []>
		<cfset var values = []>

		<cfswitch expression="#meta.fullname#">
			<cfcase value="com.apirone.core.model.bean.ComponentCatalogBundle">
				<cfset fields = [ "line_id", "model_id" ]>
				<cfset values = [
					{
						value = arguments.component.getLine().getId(),
						type  = "uuid"
					},
					{
						value = arguments.component.getModel().getId(),
						type  = "uuid"
					}
				]>
			</cfcase>

			<cfcase value="com.apirone.core.model.bean.ComponentProductItem">
				<cfset fields = [ "product_item_id" ]>
				<cfset values = [
					{
						value = arguments.component.getProductItem().getId(),
						type  = "Integer"
					}
				]>
			</cfcase>

			<cfcase value="com.apirone.core.model.bean.ComponentSignageConfigItem">
				<cfset fields = [ "signage_config_item_id" ]>
				<cfset values = [
					{
						value = arguments.component.getSignageConfigItem().getId(),
						type  = "Integer"
					}
				]>
			</cfcase>

			<cfcase value="com.apirone.core.model.bean.ComponentSignageItemProduct">
				<cfset fields = [ "signage_config_item_join_id", "product_item_join_id" ]>
				<cfset values = [
					{
						value = arguments.component.getSignageConfigItem().getId(),
						type  = "Integer"
					},
					{
						value = arguments.component.getProductItem().getId(),
						type  = "Integer"
					}
				]>
			</cfcase>

			<cfcase value="com.apirone.core.model.bean.ComponentProduct">
				<cfset fields = [ "product_id" ]>
				<cfset values = [
					{
						value = arguments.component.getProduct().getId(),
						type  = "uuid"
					}
				]>
			</cfcase>

			<cfcase value="com.apirone.core.model.bean.ComponentAttributeValue">
				<cfset fields = [ "attribute_raw_value_id" ]>
				<cfset values = [
					{
						value = arguments.component.getAttributeValue().getId(),
						type  = "Integer"
					}
				]>
			</cfcase>

			<cfdefaultcase>
				<cfset var meta = GetMetadata( component )>
				<cfthrow type="apirone.error.ComponentNotValid" message="Component [#meta.fullname#] not valid">
			</cfdefaultcase>
		</cfswitch>

		<cfreturn { "fields" = fields, "values" = values }>
	</cffunction>

	<!---
		Recupera in batch più componenti dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM components
			WHERE component_id IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="integer">
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch i componenti collegati a una lista di product_item_id.
		Utilizzato da QuotationService.getComponents() per evitare N+1.
	--->
	<cffunction name="readByProductItemIds" returntype="Query" access="public">
		<cfargument name="productItemIds" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.productItemIds )>

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM components
			WHERE product_item_id IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="integer">
			)
			ORDER BY created_at desc
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch i componenti di tipo SignageItemProduct dato
		l'ID della config segnaletica e una lista di product_item_id (join).
		Utilizzato da QuotationService.getComponents() per evitare N+1.
	--->
	<cffunction name="readBySignageItemProductJoinIds" returntype="Query" access="public">
		<cfargument name="signageConfigItemId" type="String" required="true">
		<cfargument name="productItemIds" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.productItemIds )>

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM components
			WHERE signage_config_item_join_id = <cfqueryparam value="#arguments.signageConfigItemId#" cfsqltype="Integer">
				AND product_item_join_id IN (
					<cfqueryparam value="#idsList#" list="true" cfsqltype="integer">
				)
			ORDER BY created_at desc
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch i componenti collegati agli attributi (attribute_raw_value_id).
		Utilizzato da QuotationService.getComponents() per il caricamento
		dei componenti base-attribute corrispondenti a includeBaseAttributeComponents=true.
	--->
	<cffunction name="readByAttributeValueIds" returntype="Query" access="public">
		<cfargument name="attributeValueIds" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.attributeValueIds )>

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM components
			WHERE attribute_raw_value_id IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="integer">
			)
			ORDER BY created_at desc
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch i componenti "own" (product_item_id) con override correlato
		per il calcolo prezzo. Sostituisce N chiamate a priceCalculatorRead() con una
		sola query apirone. L'override è scoped sul product_item_id del componente
		(equivalente al singolo priceCalculatorRead(componentId, productItemId)).
	--->
	<cffunction name="priceCalculatorReadByProductItemIds" returntype="Query" access="public">
		<cfargument name="productItemIds" type="Array" required="true">

		<cfif !ArrayLen( arguments.productItemIds )>
			<cfreturn QueryNew( "" )>
		</cfif>

		<cfset var idsList = ArrayToList( arguments.productItemIds )>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				c.component_id as id,

				CASE 
					WHEN co.deleted = true THEN true
					ELSE false
				END AS isDeleted,

				CASE
					WHEN co.deleted = true THEN 0
					WHEN co.quantity IS NOT NULL THEN c.quantity + co.quantity
					ELSE c.quantity
				END AS totalQuantity,

				c.raw_product_id,
				c.variant_id,
				c.color_id,
				c.product_item_id

			FROM components c

			LEFT JOIN component_overrides co 
				ON c.component_id = co.component_id 
				AND co.product_item_id = c.product_item_id
			WHERE c.product_item_id IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="integer">
			)
			ORDER BY c.created_at desc
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch gli override per una lista di (component_id, product_item_id)
		di componenti "base attribute".
	--->
	<cffunction name="readOverridesByComponentIdsAndProductItemIds" returntype="Query" access="public">
		<cfargument name="componentIds" type="Array" required="true">
		<cfargument name="productItemIds" type="Array" required="true">

		<cfif !ArrayLen( arguments.componentIds ) OR !ArrayLen( arguments.productItemIds )>
			<cfreturn QueryNew( "" )>
		</cfif>

		<cfset var componentIdsList   = ArrayToList( arguments.componentIds )>
		<cfset var productItemIdsList = ArrayToList( arguments.productItemIds )>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				component_id,
				product_item_id,
				quantity,
				deleted
			FROM component_overrides
			WHERE component_id IN (
				<cfqueryparam value="#componentIdsList#" list="true" cfsqltype="integer">
			)
			AND product_item_id IN (
				<cfqueryparam value="#productItemIdsList#" list="true" cfsqltype="integer">
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
