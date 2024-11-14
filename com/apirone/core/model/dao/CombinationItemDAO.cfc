<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

		<cfargument name="combinationItemId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT 
                combination_id::varchar, 
                *
			FROM
				combination_items
			WHERE
				combination_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.combinationItemId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="find" returntype="Query">

        <cfargument name="combinationId" type="String">
        <cfargument name="parentId" type="Numeric">

        <cfquery name="local.q" datasource="apirone">
			SELECT 
                combination_item_id, parent_id
			FROM
				combination_items
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

		<cfargument name="combinationItem" type="com.apirone.core.model.bean.CombinationItem" required="true">

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO combination_items (
                attribute_value_id,
                combination_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combinationItem.getAttributeValue().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combinationItem.getCombinationId()#">
			) RETURNING combination_item_id
		</cfquery>

		<cfreturn local.q.combination_item_id>

	</cffunction>


	<cffunction name="delete" returntype="Boolean">

        <cfargument name="combinationItemId" type="String">

        <cfquery name="local.q" datasource="apirone">
			DELETE 
            FROM combination_items 
            WHERE
                combination_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.combinationItemId#">
		</cfquery>

		<cfreturn true>

	</cffunction>

</cfcomponent>