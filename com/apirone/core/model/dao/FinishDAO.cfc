<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="finishId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT finish_id::varchar, categories::varchar, *
			FROM
				finishes
			WHERE
				finish_id = <cfqueryparam cfsqltype="varchar" value="#arguments.finishId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="readByCode">

		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT finish_id::varchar, categories::varchar, *
			FROM
				finishes
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>	
	
	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String">
		<cfargument name="categoryId" type="Numeric">

		<cfquery name="local.q" datasource="apirone">
			SELECT DISTINCT finish_id::varchar, categories::varchar, *
			FROM
				finishes

				<cfif !IsNull( arguments.str )>
					INNER JOIN texts USING ( finish_id )
				</cfif>

			WHERE 1=1
				
                <cfif !isNull(arguments.categoryId)>
					<!--- TODO: to fix 
						// https://stackoverflow.com/questions/79195450/find-record-matching-an-array-json-field
					--->
                    AND jsonb_exists_any( finishes.categories, ARRAY[21, 22]::json )
                </cfif>

				<cfif !IsNull( arguments.str )>
					AND ( 
						finishes.code ILIKE <cfqueryparam cfsqltype="Varchar" value="#arguments.str#%">
						OR texts.text ILIKE <cfqueryparam cfsqltype="Varchar" value="#arguments.str#%">
					)
				</cfif>

            ORDER BY 
                orderby
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="insert" returntype="String">

		<cfargument name="finish" type="com.apirone.core.model.bean.Finish" required="true">

        <cfset var items = getCategoriesAsArray( finish.getCategories() )>

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO finishes (
				code,
				status_id,
                categories
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.finish.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.finish.getStatus().getId()#">,
				'#SerializeJSON( items )#'
			) RETURNING finish_id
		</cfquery>

		<cfreturn local.q.finish_id.toString()>

	</cffunction>


	<cffunction name="update" returntype="String">

		<cfargument name="attribute" type="com.apirone.core.model.bean.Attribute" required="true">

        <cfquery name="local.q" datasource="apirone">
			UPDATE 
				finishes 
			SET 
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attribute.getStatus().getId()#">
			WHERE
				attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attribute.getId()#">
		</cfquery>

		<cfreturn arguments.attribute.getId()>

	</cffunction>

	<cffunction name="delete" returntype="Numeric">

		<cfargument name="finishId" type="String" required="true">

        <cfquery name="local.q" datasource="apirone">
			DELETE FROM
				finishes 
			WHERE
				finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid
			RETURNING finish_id
		</cfquery>

		<cfreturn local.q.RecordCount>

	</cffunction>

	
	<!----
		private methods 
	---->

	<cffunction access="private" name="getCategoriesAsArray" returntype="Array">

		<cfargument name="categories" required="true">

        <cfset var items = []>

        <cfloop array="#arguments.categories#" item="thisItem">

            <cfset items.add( thisItem.getId() )>

        </cfloop>

        <cfreturn items>

	</cffunction>

</cfcomponent>