<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

		<cfargument name="combinationId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				combinations
			WHERE
				combination_id = <cfqueryparam cfsqltype="integer" value="#arguments.combinationId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="find" returntype="Query">

        <cfargument name="lineId" type="String">

        <cfquery name="local.q" datasource="apirone">
			SELECT combination_id
			FROM
				combinations
                <cfif !IsNull( arguments.lineId )>
                    AND line_id = <cfqueryparam cfsqltype="varchar" value="#arguments.lineId#">
                </cfif>
            ORDER BY 
                created_at
		</cfquery>

		<cfreturn local.q>

	</cffunction>

    
	<cffunction name="insert" returntype="Numeric">

		<cfargument name="combination" type="com.apirone.core.model.bean.Combination" required="true">

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO combinations (
                size_id,
                line_id,
                finish_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getSize().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getLine().getId()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.combination.getFinish().getId()#">
			) RETURNING combination_id
		</cfquery>

		<cfreturn local.q.combination_id>

	</cffunction>


	<cffunction name="delete" returntype="Boolean">

        <cfargument name="combinationId" type="Numeric">

        <cfquery name="local.q" datasource="apirone">
			DELETE 
            FROM combinations 
            WHERE
                combination_id = <cfqueryparam cfsqltype="Integer" value="#arguments.combinationId#">
		</cfquery>

		<cfreturn true>

	</cffunction>

</cfcomponent>