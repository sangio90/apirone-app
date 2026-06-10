<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="attributeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				attribute_id::varchar, *
			FROM
				attributes
			WHERE
				attribute_id = <cfqueryparam cfsqltype="varchar" value="#arguments.attributeId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				attribute_id::varchar,
				code
			FROM
				attributes
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				attribute_id::varchar,
				COUNT(attribute_id) OVER() AS total
			FROM
				attributes
					<cfif !IsNull( arguments.str )>
						INNER JOIN texts USING ( attribute_id )
					</cfif>

			WHERE 1=1
				<cfif !IsNull( arguments.str )>
					AND texts.text ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
						OR attributes.code ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
				</cfif>

				<cfif !IsNull( arguments.statusId )>
					AND attributes.status_id = <cfqueryparam cfsqltype="varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.categoryId )>
					AND categories @> ANY ('{[#sanitizeSQL( arguments.categoryId )#]}')
				</cfif>
			GROUP BY
				attribute_id
			ORDER BY
				attribute_id

			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>

		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="attribute" type="com.apirone.core.model.bean.Attribute" required="true">

		<cfset var categories = super.getCategoriesAsArray( attribute.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO attributes (
				status_id,
				code,
				categories
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.attribute.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.attribute.getCode()#">,
				'#SerializeJSON( categories )#'
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
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.attribute.getCode()#">,
				categories = '#SerializeJSON( categories )#'
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

	<!---
		Recupera in batch più attributi dato un array di ID.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList(arguments.ids)>

		<cfquery name="local.q" datasource="apirone">
			SELECT attribute_id::varchar, *
			FROM attributes
			WHERE attribute_id::varchar IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="varchar">
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
