<cfcomponent accessors="true">

    <cffunction name="getCountries">
		
        <cfargument name="limit" required="false" type="Numeric" default="5">

        <cfquery datasource="apirone" name="local.q">
            SELECT *
            FROM public.countries
            ORDER BY RANDOM()
            LIMIT 
                <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
        </cfquery>

        <cfreturn local.q>

    </cffunction>

    <cffunction name="getStatuses" access="public" returnType="query" output="false">
        <cfargument name="limit" type="numeric" required="false" default="5">
        <cfargument name="entity" type="string" required="false" default="">

        <cfset var whereClause = "">
        <cfset var sql = "SELECT * FROM public.statuses">
        <cfset var fullQuery = "">
        <cfset var orderClause = " ORDER BY RANDOM()">
        <cfset var limitClause = " LIMIT " & arguments.limit>

        <cfif len(trim(arguments.entity))>
            <cfset var cleanEntity = Replace(arguments.entity, "'", "''", "all")>
            <cfset whereClause = " WHERE entities::text LIKE '%" & cleanEntity & "%'">
        </cfif>

        <cfset fullQuery = sql & whereClause & orderClause & limitClause>

        <cfquery name="local.q" datasource="apirone">
            #preserveSingleQuotes(fullQuery)#
        </cfquery>

        <cfreturn local.q>
    </cffunction>

    <cffunction name="getCountries">
		
        <cfargument name="limit" required="false" type="Numeric" default="5">

        <cfquery datasource="apirone" name="local.q">
            SELECT *
            FROM public.countries
            ORDER BY RANDOM()
            LIMIT 
                <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
        </cfquery>

        <cfreturn local.q>

    </cffunction>

    <cffunction name="getCities">
		
        <cfargument name="limit" required="false" type="Numeric" default="5">

        <cfquery datasource="apirone" name="local.q">
            SELECT *
            FROM public.cities
                INNER JOIN public.counties USING (county_id)
                    INNER JOIN public.states USING (state_id)
                        INNER JOIN public.countries USING (country_id)
            ORDER BY RANDOM()
            LIMIT 
                <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
        </cfquery>

        <cfreturn local.q>

    </cffunction>

    <cffunction name="getCompanyTypes">
		
        <cfargument name="limit" required="false" type="Numeric" default="5">

        <cfquery datasource="apirone" name="local.q">
            SELECT *
            FROM public.company_types
            ORDER BY RANDOM()
            LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
        </cfquery>

        <cfreturn local.q>

    </cffunction>

    <cffunction name="getRandomByTableName">
        <cfargument name="tableName" required="true" type="String">
        <cfargument name="limit" required="false" type="Numeric" default="5">
        <cfargument name="primaryKey" required="false" type="String">
        <cfargument name="escluso" required="false" type="String">
        <cfargument name="tipo" required="false" type="String">

        <cfset var safeTable = REReplace(arguments.tableName, "[^A-Za-z0-9_]", "", "all")>
        <cfset var whereClause = "">
        <cfset var hasWhere = !isNull(arguments.primaryKey) and !isNull(arguments.escluso)>
        
        <cfquery datasource="apirone" name="local.q">
            SELECT *
            FROM public.#safeTable#
            <cfif hasWhere>
                <cfif !isNull(arguments.tipo) and arguments.tipo EQ 'id'>
                    WHERE #arguments.primaryKey# != <cfqueryparam cfsqltype="Numeric" value="#arguments.escluso#">
                <cfelse>
                    WHERE #arguments.primaryKey# != <cfqueryparam cfsqltype="Varchar" value="#arguments.escluso#">::uuid
                </cfif>
            </cfif>
            ORDER BY RANDOM()
            LIMIT #arguments.limit#
        </cfquery>
        <cfreturn local.q>
    </cffunction>

    <cffunction name="getRandomProfilesByType">
        <cfargument name="type" required="true" type="String">
        <cfargument name="limit" required="false" type="Numeric" default="5">

        <cfquery datasource="apirone" name="local.q">
            SELECT *
            FROM 
                public.profiles
            WHERE 
                type = <cfqueryparam value="#arguments.type#" cfsqltype="varchar" />
            ORDER BY 
                RANDOM()
            LIMIT 
                <cfqueryparam value="#arguments.limit#" cfsqltype="integer" />
        </cfquery>

        <cfreturn local.q>
    </cffunction>

</cfcomponent>
