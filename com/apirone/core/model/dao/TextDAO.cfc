<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="textId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				text_id,
				product_id::varchar,
				finish_id::varchar,
				attribute_id::varchar,
				font_id::varchar,
				country_id::varchar,
				*
			FROM texts
			WHERE text_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.textId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="statusId" type="String">
		<cfargument name="langId" type="String">

		<cfargument name="lineId" type="String">
		<cfargument name="attributeId" type="String">
		<cfargument name="attributeValueId" type="String">
		<cfargument name="rawValueId" type="Numeric">
		<cfargument name="productCategoryId" type="Numeric">
		<cfargument name="modelId" type="String">
		<cfargument name="productId" type="String">
		<cfargument name="fontId" type="Numeric">
		<cfargument name="countryId" type="String">
		<cfargument name="articleId" type="String">

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

				<cfif !IsNull( arguments.entity )>
					AND #field.name# =
						<cfif field.type == "uuid">
							<cfqueryparam cfsqltype="Varchar" value="#value#">::uuid
						<cfelse>
							<cfqueryparam cfsqltype="#field.type#" value="#value#">
						</cfif>
				</cfif>

			<cfif !IsNull( arguments.str )>
				AND text ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
			</cfif>

			<cfif !IsNull( arguments.statusId )>
				AND texts.status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
			</cfif>

			<cfif !IsNull( arguments.lineId )>
				AND texts.line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.langId )>
				AND lang_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.langId#">
			</cfif>

			<cfif !IsNull( arguments.attributeId )>
				AND attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attributeId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.modelId )>
				AND model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.articleId )>
				AND article_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.articleId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.rawValueId )>
				AND raw_value_id = <cfqueryparam cfsqltype="Integer" value="#arguments.rawValueId#">
			</cfif>

			<cfif !IsNull( arguments.attributeValueId )>
				AND attribute_raw_value_id = <cfqueryparam cfsqltype="Integer" value="#arguments.attributeValueId#">
			</cfif>

			<cfif !IsNull( arguments.ProductCategoryId )>
				AND product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productCategoryId#">
			</cfif>

			<cfif !IsNull( arguments.finishId )>
				AND finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.productId )>
				AND product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.countryId )>
				AND country_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.countryId#">::uuid
			</cfif>

			<cfif !IsNull( arguments.fontId )>
				AND font_id = <cfqueryparam cfsqltype="Integer" value="#arguments.fontId#">
			</cfif>

			<cfif !IsNull( arguments.fromDate )>
				AND texts.created_at >= <cfqueryparam cfsqltype="Date" value="#arguments.fromDate#">
			</cfif>

			<cfif !IsNull( arguments.toDate )>
				AND texts.created_at <= <cfqueryparam cfsqltype="Date" value="#arguments.toDate#">
			</cfif>

			ORDER BY
				<!--- #super.sanitizeSQL( arguments.orderby )# ---->
				text_id DESC

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
				text_kind_id,
				status_id,
				#field.name#
			)
			VALUES
			(
				<cfqueryparam cfsqltype="Varchar" value="#arguments.text.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.text.getLang().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.text.getKind().getId()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.text.getStatus().getId()#">,

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

		<!--- <cfset field = getDBField( arguments.text.getEntity().getKey() )> --->

		<cfquery name="local.q" datasource="apirone" result="local.result">
			UPDATE texts
			SET
				text	= <cfqueryparam cfsqltype="varchar" value="#arguments.text.getName()#">,
				lang_id	= <cfqueryparam cfsqltype="varchar" value="#arguments.text.getLang().getId()#">
				<!---
				text_kind_id	= <cfqueryparam cfsqltype="varchar" value="#arguments.text.getKind().getId()#">
				status_id	= <cfqueryparam cfsqltype="varchar" value="#arguments.text.getStatus().getId()#">, 
				#field.name# =

					<cfif field.type == "uuid">
						<cfqueryparam cfsqltype="Varchar" value="#arguments.text.getEntity().getValue()#">::uuid
					<cfelse>
						<cfqueryparam cfsqltype="#field.type#" value="#arguments.text.getEntity().getValue()#">
					</cfif>
				--->

			WHERE
				text_id = <cfqueryparam cfsqltype="Integer" value="#arguments.text.getId()#">
		</cfquery>

		<cfreturn arguments.text.getId()>
	</cffunction>
</cfcomponent>
