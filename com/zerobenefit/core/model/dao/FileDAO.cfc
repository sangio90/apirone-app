<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="fileId" type="String" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			SELECT *
			FROM files
			WHERE file_id = <cfqueryparam cfsqltype="varchar" value="#arguments.fileId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction returntype="Void" name="delete">

		<cfargument name="fileId" type="String" required="true">
		<cfquery name="local.q" datasource="zerobenefit">
			DELETE
			FROM files
			WHERE file_id = <cfqueryparam cfsqltype="varchar" value="#arguments.fileId#">::uuid
		</cfquery>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="limit" required="true" type="Numeric" default="50">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="productVariantId" type="String">

		<cfquery name="local.q" datasource="zerobenefit">
			SELECT
				file_id,
				COUNT(file_id) OVER() AS total
			FROM
				files
			WHERE 1=1
	
			<cfif !isNull( arguments.productVariantId ) >
				AND variant_id = <cfqueryparam value="#arguments.productVariantId#" cfsqltype="varchar">::uuid
			</cfif>

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


		<cfquery name="local.q" datasource="zerobenefit">
			INSERT INTO files(
				name,
                type,
                size,
                width,
                height,
                alt,
                description,
                directory,
                extension, 
                #getField( arguments.entity.getType() ).name#
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.file.getName()#">,
                <cfqueryparam cfsqltype="Varchar" value="#arguments.file.getType()#">,
                <cfqueryparam cfsqltype="integer" value="#arguments.file.getSize()#">,
                <cfqueryparam cfsqltype="integer" value="#arguments.file.getWidth()#">,
                <cfqueryparam cfsqltype="integer" value="#arguments.file.getHeight()#">,
                <cfqueryparam cfsqltype="Varchar" value="#arguments.file.getAlt()#">,
                <cfqueryparam cfsqltype="Varchar" value="#arguments.file.getDescription()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.file.getDirectory()#">,
                <cfqueryparam cfsqltype="Varchar" value="#arguments.file.getExtension()#">,
                <cfqueryparam cfsqltype="Varchar" value="#arguments.entity.getId()#">::uuid
			) RETURNING file_id
		</cfquery>

		<cfreturn q.file_id>
	
	</cffunction>

</cfcomponent>