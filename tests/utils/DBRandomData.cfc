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

</cfcomponent>
