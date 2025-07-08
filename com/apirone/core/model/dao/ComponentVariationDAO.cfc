<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="componentVariationId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
                component_variations
			WHERE
				component_variation_id  <cfqueryparam cfsqltype="Integer" value="#arguments.componentVariationId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="combinationId" type="String">
		<cfargument name="productItemId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="created_at desc">

        <cfquery name="local.q" datasource="apirone">
			SELECT	
                component_variation_id,
				COUNT(component_variation_id) OVER() AS total
			FROM
            	component_variations
			WHERE 1=1
			
				<cfif !isNull( arguments.productItemId )>
					AND product_item_id = <cfqueryparam value="#arguments.productItemId#" cfsqltype="Integer">
				</cfif>

				<cfif !isNull( arguments.componentId )>
					AND component_variation_id = <cfqueryparam value="#arguments.componentId#" cfsqltype="Integer">
				</cfif>

                <!----
				<cfif !isNull( arguments.fruitId )>
					AND fruit_id = <cfqueryparam value="#arguments.fruitId#" cfsqltype="Varchar">::uuid
				</cfif>

				<cfif !isNull( arguments.fruitProductItemId )>
					AND fruit_product_item_id = <cfqueryparam value="#arguments.fruitProductItemId#" cfsqltype="Integer">
				</cfif>

				<cfif !isNull( arguments.combinationId )>
					AND combination_id = <cfqueryparam value="#arguments.combinationId#" cfsqltype="Varchar">::uuid
				</cfif>

				<cfif !isNull( arguments.lineId )>
					AND line_id = <cfqueryparam value="#arguments.lineId#" cfsqltype="Varchar">::uuid
				</cfif>

				<cfif !isNull( arguments.sizeId )>
					AND size_id = <cfqueryparam value="#arguments.sizeId#" cfsqltype="Varchar">::uuid
				</cfif>

				<cfif !isNull( arguments.attributeValueId )>
					AND attribute_raw_value_id = <cfqueryparam value="#arguments.attributeValueId#" cfsqltype="Integer">
				</cfif>
                ---->

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
		<cfargument name="componentVariationId" type="Numeric" required="true">

        <cfquery name="local.q" datasource="apirone" result="result">
			DELETE FROM 
				component_variations
			WHERE 
				component_variation_id  <cfqueryparam cfsqltype="Integer" value="#arguments.componentVariationId#">
		</cfquery>

		<cfreturn true>

	</cffunction>

	<cffunction name="insert" returntype="Numeric">

		<cfargument name="ComponentVariation" type="com.apirone.core.model.bean.ComponentVariation" required="true">

		<cfset var meta = getFieldsAndValues( arguments.component )>

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO component_variations (
                component_id,
                product_item_id,
				quantity,
                deleted
			)
			VALUES (
				<cfqueryparam cfsqltype="Numeric" value="#arguments.ComponentVariation.getComponentId()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.ComponentVariation.getProductItemId()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.ComponentVariation.getQuatity()#">,
				<cfqueryparam cfsqltype="Boolean" value="#arguments.ComponentVariation.getDeleted()#">
			) RETURNING component_variation_id
		</cfquery>

		<cfreturn local.q.component_variation_id>

	</cffunction>


	<cffunction name="update" returntype="Numeric">

		<cfargument name="componentVariation" type="com.apirone.core.model.bean.ComponentVariation" required="true">

        <cfquery name="local.q" datasource="apirone">
			UPDATE 
                component_variations 
			SET 
				quantity = <cfqueryparam cfsqltype="Numeric" value="#arguments.componentVariation.getQuantity()#">,
				deleted =  <cfqueryparam cfsqltype="Boolean" value="#arguments.componentVariation.getDeleted()#">
			WHERE 
				component_variation_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.componentVariation.getId()#">
		</cfquery>

		<cfreturn arguments.componentVariation.getId()>

	</cffunction>	

</cfcomponent>