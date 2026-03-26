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
		<cfset component["costAmount"] = 0>
		<cfquery name="verticalCost" datasource="verticale">
			SELECT TOP 1 lispre
			FROM azapi_listin
			WHERE TRIM(lisart) = <cfqueryparam value="#Trim(component.raw_product_id)#" cfsqltype="varchar">
			AND (
				(
					TRIM(liscvr) = <cfqueryparam value="#Trim(component.variant_id)#" cfsqltype="varchar"> AND 
					TRIM(liscol) = <cfqueryparam value="#Trim(component.color_id)#" cfsqltype="varchar">
				) 
				OR TRIM(liscvr) = <cfqueryparam value="#Trim(component.variant_id)#" cfsqltype="varchar">
				OR TRIM(liscol) = <cfqueryparam value="#Trim(component.color_id)#" cfsqltype="varchar">
				OR 1=1
			)
			ORDER BY
				CASE
					WHEN 
						TRIM(liscvr) = <cfqueryparam value="#Trim(component.variant_id)#" cfsqltype="varchar">
						AND TRIM(liscol) = <cfqueryparam value="#Trim(component.color_id)#" cfsqltype="varchar"> 
						THEN 1
					WHEN 
						TRIM(liscvr) = <cfqueryparam value="#Trim(component.variant_id)#" cfsqltype="varchar"> 
						THEN 2
					WHEN 
						TRIM(liscol) = <cfqueryparam value="#Trim(component.color_id)#" cfsqltype="varchar"> 
						THEN 3
					ELSE 4
				END
		</cfquery>

		<cfif verticalCost.recordCount GT 0>
			<cfset component["costAmount"] = verticalCost.lispre[1]>
		</cfif>

		<cfquery name="rawProductData" datasource="verticale">
			SELECT
				ardesart as raw_product_name,
				CASE WHEN artipmat = 'LAV' THEN 'LV' ELSE 'MP' END AS raw_product_processiong_type
			FROM
				azapi_artico a
			WHERE
				arcodart = <cfqueryparam cfsqltype="varchar" value="#component.raw_product_id#">
		</cfquery>

		<cfif rawProductData.recordCount GT 0>
			<cfset component["raw_product_name"] = rawProductData.getRow(1).raw_product_name>
			<cfset component["raw_product_processiong_type"] = rawProductData.getRow(1).raw_product_processiong_type>
		<cfelse>
			<cfset component["raw_product_name"] = "">
			<cfset component["raw_product_processiong_type"] = "">
		</cfif>

		<cfreturn component>
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

			<cfif arguments.limit GTE 0>
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
</cfcomponent>
