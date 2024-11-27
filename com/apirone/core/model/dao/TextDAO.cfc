<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

		<cfargument name="textId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM texts
			WHERE text_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.textId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String">
		<cfargument name="statusId" type="String">
		<cfargument name="langId" type="String">
		
		<cfargument name="attributeId" type="String">
		<cfargument name="attributeValueId" type="String">
		<cfargument name="lineCategoryId" type="Numeric">
		<cfargument name="sizeId" type="String">

		<cfargument name="fromDate" type="Date">
		<cfargument name="toDate" type="Date">
		<cfargument name="entity" type="com.apirone.core.model.bean.Entity">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="texts.created_at DESC">

		<cfif !IsNull( arguments.entity )>
			<cfset field = super.getDBField( arguments.entity.getKey() )>
			<cfset value = arguments.entity.getValue()>
		</cfif>


		<cfquery name="local.q" datasource="apirone">
			SELECT
             	text_id, 
				COUNT( text_id ) OVER() AS total
			FROM texts
                INNER JOIN langs USING ( lang_id )
			WHERE 1=1

			<cfif !isNull( arguments.entity ) >
				
				AND #field.name# = 
					<cfif field.type == "uuid">
						<cfqueryparam cfsqltype="Varchar" value="#value#">::uuid
					<cfelse>
						<cfqueryparam cfsqltype="#field.type#" value="#value#">
					</cfif>
			</cfif>

			<cfif !isNull( arguments.str ) >
				AND text ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
			</cfif>

			<cfif !isNull( arguments.statusId ) >
				AND texts.status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
			</cfif>

			<cfif !isNull( arguments.langId ) >
				AND lang_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.langId#">
			</cfif>

			<cfif !isNull( arguments.attributeId ) >
				AND attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">::uuid
			</cfif>

			<cfif !isNull( arguments.sizeId ) >
				AND size_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.sizeId#">::uuid
			</cfif>

			<cfif !isNull( arguments.attributeValueId ) >
				AND attribute_value_id = <cfqueryparam cfsqltype="Integer" value="#arguments.attributeValueId#">
			</cfif>

			<cfif !isNull( arguments.lineCategoryId ) >
				AND line_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.lineCategoryId#">
			</cfif>

			<cfif !isNull( arguments.finishId ) >
				AND finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid
			</cfif>

			<cfif !isNull( arguments.fromDate ) >
				AND texts.created_at >= <cfqueryparam cfsqltype="Date" value="#arguments.fromDate#">
			</cfif>

			<cfif !isNull( arguments.toDate ) >
				AND texts.created_at <= <cfqueryparam cfsqltype="Date" value="#arguments.toDate#">
			</cfif>

			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				LIMIT  
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET 
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>


	<cffunction name="insert" returntype="Numeric">

		<cfargument name="text" type="com.apirone.core.model.bean.Text" required="true">

		<cfset field = super.getDBField( arguments.text.getEntity().getKey() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO texts (
				text,
				lang_id,
				#field.name#
			)
			VALUES
			(
				<cfqueryparam cfsqltype="Varchar" value="#arguments.text.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.text.getLang().getId()#">,
				
				<cfif field.type == "uuid">
					<cfqueryparam cfsqltype="varchar" value="#arguments.text.getEntity().getValue()#">::uuid
				<cfelse>
					<cfqueryparam cfsqltype="#field.type#" value="#arguments.text.getEntity().getValue()#">
				</cfif>
			)
			RETURNING text_id
		</cfquery>

		<cfreturn local.q.text_id>

	</cffunction>


	<cffunction name="update" returntype="Numeric">

		<cfargument name="text" type="com.apirone.core.model.bean.Text" required="true">

		<cfset field = getDBField( arguments.text.getEntity().getKey() )>

		<cfquery name="local.q" datasource="apirone">
			UPDATE texts 
			SET
				text	= <cfqueryparam cfsqltype="varchar" value="#arguments.text.getName()#">,
				lang_id	= <cfqueryparam cfsqltype="varchar" value="#arguments.text.getLang().getId()#">,
				#field.name# = 

					<cfif field.type == "uuid">
						<cfqueryparam cfsqltype="Varchar" value="#arguments.text.getEntity().getValue()#">::uuid
					<cfelse>
						<cfqueryparam cfsqltype="#field.type#" value="#arguments.text.getEntity().getValue()#">
					</cfif>
				
			WHERE 
				text_id = <cfqueryparam cfsqltype="Integer" value="#arguments.text.getId()#">
		</cfquery>

		<cfreturn arguments.text.getId()>

	</cffunction>

</cfcomponent>