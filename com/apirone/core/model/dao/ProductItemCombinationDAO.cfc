<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

		<cfargument name="productItemId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT 
                combination_id::varchar, 
                *
			FROM
				product_items
			WHERE
				product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="find" returntype="Query">

        <cfargument name="fruitId" type="String">
        <cfargument name="combinationId" type="String">
        <cfargument name="parentId" type="Numeric">

        <cfquery name="local.q" datasource="apirone">
			SELECT 
                product_item_id, parent_id
			FROM
				product_items
			WHERE 1=1

				AND parent_id
					<cfif IsNull( arguments.parentId ) >
						IS NULL
					<cfelse>
						= <cfqueryparam cfsqltype="Integer" value="#arguments.parentId#">
					</cfif>

                <cfif !IsNull( arguments.combinationId )>
                    AND combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationId#">::uuid
                </cfif>
        
                <cfif !IsNull( arguments.fruitId )>
                    AND fruit_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.fruitId#">::uuid
                </cfif>
        
            ORDER BY 
                orderby
		</cfquery>

		<cfreturn local.q>

	</cffunction>

    
	<cffunction name="insert" returntype="String">

		<cfargument name="combinationItem" type="com.apirone.core.model.bean.ProductItem" required="true">

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO product_items (
                attribute_raw_value_id,
                combination_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combinationItem.getAttributeValue().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combinationItem.getCombinationId()#">
			) RETURNING product_item_id
		</cfquery>

		<cfreturn local.q.product_item_id>

	</cffunction>


	<cffunction name="delete" returntype="Boolean">

        <cfargument name="fruitId" type="String">
        <cfargument name="attributeId" type="String">
        <cfargument name="combinationId" type="String">
        <cfargument name="productItemId" type="String">

		<cfif IsNull( arguments.productItemId )
			AND IsNull( arguments.combinationId )
			AND IsNull( arguments.attributeId )
			AND IsNull( arguments.fruitId )>

			<cfthrow type="ApirOne.errors.NoArgumentsPassed" message="At least one parameter is required to delete">

		</cfif>

		<cfquery datasource="apirone">
			DELETE 
			FROM product_items
			WHERE 1=1
				
				<cfif !IsNull( arguments.productItemId )>
					AND product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
				</cfif>

				<cfif !IsNull( arguments.combinationId )>
					AND combination_id = <cfqueryparam cfsqltype="Integer" value="#arguments.combinationId#">
				</cfif>

				<cfif !IsNull( arguments.attributeId )>
					AND attribute_raw_value_id IN (
						SELECT attribute_raw_value_id 
						FROM attributes_raw_values 
						WHERE attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">
					)
				</cfif>
		</cfquery>

		<!---
        <cfquery name="local.q" datasource="apirone">
			DELETE 
            FROM product_items 
            WHERE
                product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
		</cfquery>
		---->

		<cfreturn true>

	</cffunction>


	<cffunction name="deleteComponents" returntype="Boolean">

		<cfargument name="productItemId" type="Numeric" required="true">

        <cfquery name="local.q" datasource="apirone">
			DELETE FROM components 
			WHERE
				product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
		</cfquery>

		<cfreturn true>

	</cffunction>

</cfcomponent>