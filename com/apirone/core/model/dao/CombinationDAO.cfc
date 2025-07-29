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

	<cffunction name="getByProductId" output="false">
		<cfargument name="productId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			    combination_id::varchar
			FROM
    			combinations
			WHERE
	    		product_id = <cfqueryparam cfsqltype="varchar" value="#arguments.productId#">::uuid
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

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="combinationId" type="String">

		<cfquery name="local.q" datasource="apirone">
			DELETE 
            FROM 
                combinations
			WHERE
		    	combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
		</cfquery>

		<cfreturn true>
	</cffunction>
</cfcomponent>
