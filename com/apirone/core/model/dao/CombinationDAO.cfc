<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

		<cfargument name="combinationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT 
				combination_id::varchar,
				size_id::varchar,
                line_id::varchar,
                finish_id::varchar,
				*
			FROM
				combinations
			WHERE
				combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="find" returntype="Query">

        <cfargument name="lineId" type="String">
        <cfargument name="sizeId" type="String">
        <cfargument name="finishId" type="String">

        <cfquery name="local.q" datasource="apirone">
			SELECT combination_id::varchar
			FROM
				combinations
			WHERE 1=1
                
				<cfif !IsNull( arguments.lineId )>
                    AND line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
                </cfif>

                <cfif !IsNull( arguments.finishId )>
                    AND finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid
                </cfif>

                <cfif !IsNull( arguments.sizeId )>
                    AND size_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.sizeId#">::uuid
                </cfif>

            ORDER BY 
                created_at
		</cfquery>

		<cfreturn local.q>

	</cffunction>

    
	<cffunction name="insert" returntype="String">

		<cfargument name="combination" type="com.apirone.core.model.bean.Combination" required="true">

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO combinations (
                size_id,
                line_id,
                finish_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getSize().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getLine().getId()#">::uuid,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getFinish().getId()#">::uuid
			) RETURNING combination_id
		</cfquery>

		<cfreturn local.q.combination_id.toString()>

	</cffunction>

	<cffunction name="delete" returntype="Boolean">

        <cfargument name="combinationId" type="String">

        <cfquery name="local.q" datasource="apirone">
			DELETE 
            FROM combinations 
            WHERE
                combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationId#">::uuid
		</cfquery>

		<cfreturn true>

	</cffunction>

</cfcomponent>