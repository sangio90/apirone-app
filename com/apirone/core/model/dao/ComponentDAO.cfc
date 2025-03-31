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
		<cfargument name="sizeId" type="String">
		<cfargument name="combinationId" type="String">
		<cfargument name="roductItemId" type="Numeric">
		<cfargument name="fruitId" type="String">
		<cfargument name="fruitCombinationitemId" type="String">

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
			
			<cfif !isNull( arguments.roductItemId )>
				AND product_item_id = <cfqueryparam value="#arguments.roductItemId#" cfsqltype="Integer">
			</cfif>

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

			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer"> ROWS
				FETCH NEXT <cfqueryparam value="#arguments.limit#" cfsqltype="integer"> ROWS ONLY;
			</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>	

    
	<cffunction name="delete" returntype="Boolean">

		<cfargument name="component" type="com.apirone.core.model.bean.Component" required="true">

        <cfquery name="local.q" datasource="apirone" result="result">
			DELETE FROM 
				components
			WHERE 1=1
				AND raw_product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.component.getRawProduct().getId()#">
				AND variant_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.component.getVariant().getId()#">
				AND color_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.component.getColor().getId()#">
				AND

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentLineSize" )>
					line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.component.getLine().getId()#">::uuid
					AND size_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.component.getSize().getId()#">::uuid
				</cfif>

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentProductItem" )>
					product_item_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.component.getProductItem().getId()#">
				</cfif>

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentCombination" )>
					combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.component.getCombination().getId()#">::uuid
				</cfif>

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentFruit" )>
					fruit_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.component.getFruit().getId()#">::uuid
				</cfif>				
		</cfquery>

		<cfreturn true>

	</cffunction>

	<cffunction name="insert" returntype="Numeric">

		<cfargument name="component" type="com.apirone.core.model.bean.Component" required="true">

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO components (
				raw_product_id,
				color_id,
				variant_id,
				quantity,

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentLineSize" )>
					line_id,
					size_id
				</cfif>

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentProductItem" )>
					product_item_id
				</cfif>

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentCombination" )>
					combination_id
				</cfif>

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentFruit" )>
					fruit_id
				</cfif>

			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.component.getRawProduct().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.component.getColor().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.component.getVariant().getId()#">,
				<cfqueryparam cfsqltype="Numeric" value="#arguments.component.getQuantity()#">,

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentLineSize" )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.component.getLine().getId()#">::uuid,
					<cfqueryparam cfsqltype="Varchar" value="#arguments.component.getSize().getId()#">::uuid
				</cfif>

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentProductItem" )>
					<cfqueryparam cfsqltype="Numeric" value="#arguments.component.getProductItem().getId()#">
				</cfif>

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentCombination" )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.component.getCombination().getId()#">::uuid
				</cfif>

				<cfif IsInstanceOf( component, "com.apirone.core.model.bean.ComponentFruit" )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.component.getFruit().getId()#">::uuid
				</cfif>

			) RETURNING component_id
		</cfquery>

		<cfreturn local.q.component_id>

	</cffunction>

</cfcomponent>