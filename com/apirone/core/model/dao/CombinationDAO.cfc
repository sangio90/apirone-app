<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="combinationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			    combination_id::varchar,
    			product_id::varchar,
	    		*
			FROM
		    	combinations
			WHERE
			    combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find">
		<cfargument name="productId" type="String" required="true">
		<cfargument name="statusId" type="String">
		<cfargument name="str" type="String">
		<cfargument name="orderby" required="true" type="String" default="product.product_id">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			    combination_id::varchar,
				COUNT(combination_id) OVER() AS total
			FROM
    			combinations
			WHERE
	    		product_id = <cfqueryparam cfsqltype="varchar" value="#arguments.productId#">::uuid

				<cfif !IsNull( arguments.statusId )>
					AND status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND #super.createOrConditions( arguments.str, "combination" )#
				</cfif>

			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="findByListOfProductItemIds" access="public">
		<cfargument name="productItemIds" type="array" required="true">

		<cfset var N = arrayLen(arguments.productItemIds)>
		<cfset var idsList = arrayToList(arguments.productItemIds)>
		<cfset var q = "">

		<cfquery name="q" datasource="apirone">
			SELECT cpi.combination_id
			FROM combination_product_items cpi
			GROUP BY cpi.combination_id
			HAVING
			COUNT(*) = <cfqueryparam value="#N#" cfsqltype="cf_sql_integer">
			AND COUNT(CASE
			WHEN cpi.product_item_id IN (
			<cfqueryparam value="#idsList#" list="true" cfsqltype="cf_sql_integer">
			)
			THEN 1
			END) = <cfqueryparam value="#N#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="combination" type="com.apirone.core.model.bean.Combination" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO combinations (
				combination,
	    		product_id,
		    	status_id
			)
			VALUES (
			    <cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getName()#">,
			    <cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getProductId()#">::uuid,
    			<cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getStatus().getId()#">
			) RETURNING combination_id
		</cfquery>

		<cfreturn local.q.combination_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="combination" type="com.apirone.core.model.bean.Combination" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				combinations
			SET
				combination = <cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getName()#">
			WHERE
				combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.combination.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="combinationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
            FROM
                combinations
			WHERE
		    	combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationId#">::uuid
		</cfquery>

		<cfreturn true>
	</cffunction>
</cfcomponent>
