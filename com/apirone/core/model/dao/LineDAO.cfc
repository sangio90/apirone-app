<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="lineId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT line_id::varchar, *
			FROM
				lines
			WHERE
				line_id = <cfqueryparam cfsqltype="varchar" value="#arguments.lineId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				line_id::varchar,
				*
			FROM
				lines
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	
	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String">
		<cfargument name="categoryId" type="Numeric">

		<cfquery name="local.q" datasource="apirone">
			SELECT line_id::varchar
			FROM
				lines
			WHERE 1=1
				
				<cfif !IsNull( arguments.categoryId )>
					AND lines.line_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND 
					( 
						lines.code ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
						OR lines.line ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
					)
				</cfif>

            ORDER BY 
                code
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="line" type="com.apirone.core.model.bean.Line" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO lines (
				code,
				line,
				status_id,
				line_category_id,
				thickness_id,
				orderby
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.line.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.line.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.line.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.line.getCategory().getId()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.line?.getTickness()?.getId()#">,
				10
			) RETURNING line_id
		</cfquery>

		<cfreturn local.q.line_id.toString()>
	</cffunction>


	<cffunction name="update" returntype="String">
		<cfargument name="line" type="com.apirone.core.model.bean.Line" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				lines
			SET
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getStatus().getId()#">,
				line = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getName()#">,
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getCode()#">,
				line_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.line.getCategory().getId()#">,
				thickness_id = <cfqueryparam cfsqltype="Integer" value="#arguments.line?.getTickness()?.getId()#">,
				orderby = 20
			WHERE
				line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.line.getId()#">::uuid
		</cfquery>
		
		<cfreturn arguments.line.getId()>
	
	</cffunction>
	

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="lineId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				lines
			WHERE
				line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
			RETURNING line_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

</cfcomponent>

