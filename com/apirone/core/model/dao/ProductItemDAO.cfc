<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

		<cfargument name="roductItemId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT 
                combination_id::varchar, 
                *
			FROM
				product_items
			WHERE
				product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.roductItemId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="find" returntype="Query">

        <cfargument name="combinationId" type="String">
        <cfargument name="parentId" type="Numeric">

        <cfquery name="local.q" datasource="apirone">
			SELECT 
                product_item_id, parent_id
			FROM
				product_items
			WHERE 1=1
                
                <cfif IsNull( arguments.parentId ) >
                    AND parent_id IS NULL
                <cfelse>
                    AND parent_id = <cfqueryparam cfsqltype="Integer" value="#arguments.parentId#">
                </cfif>

                <cfif !IsNull( arguments.combinationId )>
                    AND combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationId#">::uuid
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
                attribute_value_id,
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
        <cfargument name="roductItemId" type="String">

		<cfif IsNull( arguments.roductItemId )
			AND IsNull( arguments.combinationId )
			AND IsNull( arguments.attributeId )
			AND IsNull( arguments.roductItemId )
			AND IsNull( arguments.fruitId )>

			<cfthrow type="ApirOne.errors.NoArgumentsPassed" message="At least one parameter is required to delete">

		</cfif>

		<cfquery datasource="apirone">
			DELETE 
			FROM product_items
			WHERE 1=1
				
				<cfif !IsNull( arguments.roductItemId )>
					AND product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.roductItemId#">
				</cfif>

				<cfif !IsNull( arguments.combinationId )>
					AND combination_id = <cfqueryparam cfsqltype="Integer" value="#arguments.combinationId#">
				</cfif>

				<cfif !IsNull( arguments.attributeId )>
					AND attribute_value_id IN (
						SELECT attribute_value_id 
						FROM attribute_values 
						WHERE attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">
					)
				</cfif>
		</cfquery>

		<!---
        <cfquery name="local.q" datasource="apirone">
			DELETE 
            FROM product_items 
            WHERE
                product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.roductItemId#">
		</cfquery>
		---->

		<cfreturn true>

	</cffunction>


	<cffunction name="deleteComponents" returntype="Boolean">

		<cfargument name="roductItemId" type="Numeric" required="true">

        <cfquery name="local.q" datasource="apirone">
			DELETE FROM components 
			WHERE
				product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.roductItemId#">
		</cfquery>

		<cfreturn true>

	</cffunction>

</cfcomponent>