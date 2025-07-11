<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="fileId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM files
			WHERE file_id = <cfqueryparam cfsqltype="varchar" value="#arguments.fileId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Void" name="delete">

		<cfargument name="fileId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM files
			WHERE file_id = <cfqueryparam cfsqltype="varchar" value="#arguments.fileId#">::uuid
		</cfquery>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="productId" type="String">
		<cfargument name="productItemId" type="Numeric">
		<cfargument name="typeId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="50">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				file_id,
				COUNT(file_id) OVER() AS total
			FROM
				files
			WHERE 1=1
	
			<cfif !isNull( arguments.productId )>
				AND product_id = <cfqueryparam value="#arguments.productId#" cfsqltype="Varchar">::uuid
			</cfif>

			<cfif !isNull( arguments.productItemId )>
				AND product_item_id = <cfqueryparam value="#arguments.productItemId#" cfsqltype="Integer">
			</cfif>

			<cfif !isNull( arguments.typeId )>
				AND type_id = <cfqueryparam value="#arguments.typeId#" cfsqltype="Varchar">
			</cfif>

			<cfif arguments.limit GT 0>
				LIMIT  
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET 
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>

            ORDER BY 
                created_at
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

</cfcomponent>