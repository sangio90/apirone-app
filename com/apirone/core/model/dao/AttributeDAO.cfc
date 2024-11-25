<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

		<cfargument name="attributeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT 
				attribute_id::varchar, 
				*
			FROM
				attributes
			WHERE
				attribute_id = <cfqueryparam cfsqltype="varchar" value="#arguments.attributeId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String">

        <cfquery name="local.q" datasource="apirone">
			SELECT 
				attribute_id::varchar
			FROM
				attributes
					<cfif !IsNull( arguments.str )>
						INNER JOIN texts USING ( attribute_id )
					</cfif>
			WHERE 1=1
				<cfif !IsNull( arguments.str )>
					AND texts.text ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.str#%">
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND attributes.status_id = <cfqueryparam cfsqltype="varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.categoryId )>
					<!--- INFO: with cfqueryparam not works --->
					AND categories @> ANY ('{[#sanitizeSQL(arguments.categoryId)#]}')
				</cfif>
            ORDER BY 
                attribute_id
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="insert" returntype="String">

		<cfargument name="attribute" type="com.apirone.core.model.bean.Attribute" required="true">

		<cfset var categories = super.getCategoriesAsArray( attribute.getCategories() )>

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO attributes (
				status_id,
				categories
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.attribute.getStatus().getId()#">,
				'#SerializeJSON(categories)#'
			) RETURNING attribute_id::varchar
		</cfquery>

		<cfreturn local.q.attribute_id>

	</cffunction>


	<cffunction name="update" returntype="String">

		<cfargument name="attribute" type="com.apirone.core.model.bean.Attribute" required="true">

		<cfset var categories = super.getCategoriesAsArray( attribute.getCategories() )>

        <cfquery name="local.q" datasource="apirone">
			UPDATE 
				attributes 
			SET 
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attribute.getStatus().getId()#">,
				categories = '#SerializeJSON(categories)#'
			WHERE
				attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attribute.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.attribute.getId()>

	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="attributeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				attributes
			WHERE
				attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">::uuid
			RETURNING attribute_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>


</cfcomponent>