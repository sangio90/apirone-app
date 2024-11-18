<cfcomponent accessors="true">

	<cffunction name="getField" output="No" returntype="Struct">
        
		<cfargument name="type" required="Yes" type="String">
        
        <cfset var data = {
            "C" = {
                "table" = "companies",
                "name"  = "company_id",
            },
            "E" = {
                "table" = "employees",
                "name"  = "employee_id",
            },
			"PV" = {
                "table" = "variants",
                "name"  = "variant_id",
            }
        }>

		<cfreturn data[ arguments.type ]>

	</cffunction>
	

	<cffunction name="createFilters" returntype="String">

		<cfargument name="filter" required="false" type="Array">

	    <cfset var result = "">
		
		<cfloop array="#arguments.filter.getFields()#" item="i">					

	        <cfsavecontent variable="sqlString">
				
	            <cfoutput> 
				
					<cfswitch expression="#i.getOperator()#">
				
						<cfcase value="EQUAL">
							AND #i.getField()# = <cfqueryparam cfsqltype="#i.getType()#" value="#i.getValue()#">
						</cfcase>
						<cfcase value="STARTWITH">
							AND #i.getField()# ILIKE <cfqueryparam cfsqltype="#i.getType()#" value="#i.getValue()#%">
						</cfcase>
						<cfcase value="ENDWITH">
							AND #i.getField()# ILIKE <cfqueryparam cfsqltype="#i.getType()#" value="%#i.getValue()#">
						</cfcase>
						<cfcase value="CONTAINS">
							AND #i.getField()# ILIKE <cfqueryparam cfsqltype="#i.getType()#" value="%#i.getValue()#%">
						</cfcase>
						<cfcase value="GREATER">
							AND #i.getField()# > <cfqueryparam cfsqltype="#i.getType()#" value="#i.getValue()#">
						</cfcase>
						<cfcase value="LESS">
							AND #i.getField()# < <cfqueryparam cfsqltype="#i.getType()#" value="#i.getValue()#">
						</cfcase>
						<cfcase value="GREATEREQUAL">
							AND #i.getField()# >= <cfqueryparam cfsqltype="#i.getType()#" value="#i.getValue()#">
						</cfcase>
						<cfcase value="LESSEQUAL">
							AND #i.getField()# <= <cfqueryparam cfsqltype="#i.getType()#" value="#i.getValue()#">
						</cfcase>
						<cfcase value="IN">
							AND #i.getField()# IN (<cfqueryparam cfsqltype="#i.getType()#" value="#i.getValue()#">) 
						</cfcase>
					
					</cfswitch>
			
	        	</cfoutput> 
	        </cfsavecontent>
	      
	        <cfset result = result & sqlString>

	    </cfloop>		

	    <cfreturn result>

	</cffunction>

	<cffunction access="private" name="getCategoriesAsArray" returntype="Array">
		<cfargument name="categories" required="true">

		<cfset var items = []>

		<cfloop array="#arguments.categories#" item="local.thisItem">
			<cfset items.add( local.thisItem.getId() )>
		</cfloop>

		<cfreturn items>
	</cffunction>	


	<cffunction name="sanitizeSQL" returntype="String">

		<cfargument name="sql" type="String">

	    <cfreturn REReplace( arguments.sql , "[^A-Za-z0-9_ ,.]", "", "all" )>

	</cffunction>	


	<cffunction name="getDBField" returntype="Struct">

		<cfargument name="field" type="String" required="true">

		<!----
			TODO: Loaded from wirebox not works.
		---->
		<cfset var DBUtil = new com.apirone.core.util.DBUtil()>

	    <cfreturn DBUtil.getDBField( arguments.field )>

	</cffunction>	

</cfcomponent>