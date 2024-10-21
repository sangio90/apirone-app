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
		<cfargument name="attributeValueId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="langs.orderby">

		<cfquery name="local.q" datasource="apirone">
			SELECT
             	text_id, 
				COUNT( text_id ) OVER() AS total
			FROM texts
                INNER JOIN langs USING ( lang_id )
			WHERE 1=1

			<cfif !isNull( arguments.str ) >
				AND text ILIKE <cfqueryparam cfsqltype="Varchar" value="#arguments.str#%">
			</cfif>

			<cfif !isNull( arguments.statusId ) >
				AND status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
			</cfif>

			<cfif !isNull( arguments.langId ) >
				AND lang_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.langId#">
			</cfif>

			<cfif !isNull( arguments.attributeId ) >
				AND attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">
			</cfif>

			<cfif !isNull( arguments.attributeValueId ) >
				AND attribute_value_id = <cfqueryparam cfsqltype="Integer" value="#arguments.attributeValueId#">
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
				#field#
			)
			VALUES
			(
				<cfqueryparam cfsqltype="varchar" value="#arguments.text.getName()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.text.getLang().getId()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.text.getEntity().getValue()#">
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
				#field#	= <cfqueryparam cfsqltype="varchar" value="#arguments.text.getEntity().getValue()#">
			WHERE 
				text_id = <cfqueryparam cfsqltype="Integer" value="#arguments.text.getId()#">
		</cfquery>

		<cfreturn arguments.text.getId()>

	</cffunction>

</cfcomponent>