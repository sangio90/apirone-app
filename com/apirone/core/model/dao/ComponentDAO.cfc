<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="componentId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				components
			WHERE
				component_id = <cfqueryparam cfsqltype="Integer" value="#arguments.componentId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="lineId" type="String">
		<cfargument name="modelId" type="String">
		<cfargument name="productId" type="String">
		<cfargument name="productItemId" type="Numeric">
		<cfargument name="attributeValueId" type="String">

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
		<!--- <cfargument name="component" type="com.apirone.core.model.bean.Component" required="true"> --->
		<cfargument name="componentId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone" result="result">
			DELETE FROM
				components
			WHERE
				component_id = <cfqueryparam cfsqltype="Integer" value="#arguments.componentId#">
		</cfquery>

		<cffile action="APPEND" file="#ExpandPath( "/debug.log" )#" output="#Now()# delete method: #result.sql#">

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
