<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="sizeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT size_id::varchar, *
			FROM
				sizes
			WHERE
				size_id = <cfqueryparam cfsqltype="varchar" value="#arguments.sizeId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				size_id::varchar,
				categories::varchar,
				*
			FROM
				sizes
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="str" type="String">
		<cfargument name="categoryId" type="Numeric">
		<cfargument name="lineId" type="String">

		<cfargument name="orderby" required="true" type="String" default="sizes.code">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT DISTINCT
				size_id::varchar,
				sizes.code,
				orderby,
				COUNT(size_id) OVER() AS total
			FROM
				sizes
					<cfif !IsNull( arguments.lineId )>
						INNER JOIN products USING ( size_id )
					</cfif>

			WHERE 1=1

				<cfif !IsNull( arguments.lineId )>
					AND products.line_id = <cfqueryparam value="#arguments.lineId#" cfsqltype="varchar">::uuid
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND sizes.code ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
				</cfif>

				<cfif !IsNull( arguments.categoryId )>
					AND categories @> ANY ('{[#arguments.categoryId#]}')
				</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="size" type="com.apirone.core.model.bean.Size" required="true">

		<cfset var categories = super.getCategoriesAsArray( size.getCategories() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO sizes (
				code,
				size,
				status_id,
				categories,
				fruits_count
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.size.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.size.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.size.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Other" value="#SerializeJSON( categories )#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.size.getFruitsCount()#">
			) RETURNING size_id
		</cfquery>

		<cfreturn local.q.size_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="size" type="com.apirone.core.model.bean.Size" required="true">

		<cfset var categories = SerializeJSON( super.getCategoriesAsArray( size.getCategories() ) )>

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				sizes
			SET
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.size.getStatus().getId()#">,
				size = <cfqueryparam cfsqltype="Varchar" value="#arguments.size.getName()#">,
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.size.getCode()#">,
				categories = <cfqueryparam cfsqltype="Other" value="#categories#">,
				fruits_count = <cfqueryparam cfsqltype="Integer" value="#arguments.size.getFruitsCount()#">
			WHERE
				size_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.size.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.size.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="sizeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				sizes
			WHERE
				size_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.sizeId#">::uuid
			RETURNING size_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
