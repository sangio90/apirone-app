<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction returntype="Query" name="read">
		<cfargument name="fileId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT file_id::varchar, *
			FROM files
			WHERE file_id = <cfqueryparam cfsqltype="varchar" value="#arguments.fileId#">::uuid
			AND deleted_at IS NULL
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="productId" type="String">
		<cfargument name="productItemId" type="Numeric">
		<cfargument name="attributeValueId" type="Numeric">
		<cfargument name="combinationId" type="String">
		<cfargument name="typeId" type="String">
		<cfargument name="quotationItemId" type="String">
		<cfargument name="quotationStatusHistoryId" type="String">
		<cfargument name="pictogramId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="50">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderBy" required="true" type="String" default="created_at">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				file_id::varchar,
				COUNT(file_id) OVER() AS total
			FROM
				files
			WHERE deleted_at IS NULL

			<cfif !IsNull( arguments.productId )>
				AND product_id = <cfqueryparam value="#arguments.productId#" cfsqltype="Varchar">::uuid
			</cfif>

			<cfif !IsNull( arguments.productItemId )>
				AND product_item_id = <cfqueryparam value="#arguments.productItemId#" cfsqltype="Integer">
			</cfif>

			<cfif !IsNull( arguments.combinationId )>
				AND combination_id = <cfqueryparam value="#arguments.combinationId#" cfsqltype="Varchar">::uuid
			</cfif>

			<cfif !IsNull( arguments.attributeValueId )>
				AND attribute_raw_value_id = <cfqueryparam value="#arguments.attributeValueId#" cfsqltype="Integer">
			</cfif>

			<cfif !IsNull( arguments.typeId )>
				AND type_id = <cfqueryparam value="#arguments.typeId#" cfsqltype="Varchar">
			</cfif>
			
			<cfif !IsNull( arguments.quotationItemId )>
				AND quotation_item_id = <cfqueryparam value="#arguments.quotationItemId#" cfsqltype="Varchar">::uuid
			</cfif>
			
			<cfif !IsNull( arguments.quotationStatusHistoryId )>
				AND quotation_status_history_id = <cfqueryparam value="#arguments.quotationStatusHistoryId#" cfsqltype="Integer">
			</cfif>

			<cfif !IsNull( arguments.pictogramId )>
				AND pictogram_id = <cfqueryparam value="#arguments.pictogramId#" cfsqltype="Integer">
			</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderBy )#

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
		<cfargument name="file" type="com.apirone.core.model.bean.File" required="true">
		<cfargument name="entity" type="com.apirone.core.model.bean.Entity" required="true">

		<cfset var dbField = getDBField( arguments.entity.getKey() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO files(
				name,
				type_id,
				kind_id,
				size,
				width,
				height,
				alt,
				description,
				directory,
				extension,
				#dbField.name#
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.file.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.file.getType().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.file.getKind().getId()#">,
				<cfqueryparam cfsqltype="integer" value="#arguments.file.getSize()#">,
				<cfqueryparam cfsqltype="integer" value="#arguments.file.getWidth()#">,
				<cfqueryparam cfsqltype="integer" value="#arguments.file.getHeight()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.file.getAlt()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.file.getDescription()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.file.getDirectory()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.file.getExtension()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.entity.getValue()#">::#dbField.type#
			) RETURNING file_id
		</cfquery>

		<cfreturn q.file_id>
	</cffunction>

	<cffunction returntype="Boolean" name="delete">
		<cfargument name="fileId" type="String" required="true">
		
		<cfquery name="local.q" datasource="apirone" result="result">
			UPDATE files
			SET deleted_at = CURRENT_TIMESTAMP(0)
			WHERE file_id = <cfqueryparam cfsqltype="varchar" value="#arguments.fileId#">::uuid
		</cfquery>

		<cfreturn true>

	</cffunction>

</cfcomponent>
