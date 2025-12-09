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

	<cffunction name="find" output="false">
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
					AND combination ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
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

	<cffunction name="insert" returntype="String">
		<cfargument name="combination" type="com.apirone.core.model.bean.Combination" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO combinations (
	    		product_id,
		    	status_id
			)
			VALUES (
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
