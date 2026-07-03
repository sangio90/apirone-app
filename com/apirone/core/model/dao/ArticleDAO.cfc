<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="articleId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT article_id::varchar, *
			FROM
				articles
			WHERE
				article_id = <cfqueryparam cfsqltype="varchar" value="#arguments.articleId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				article_id::varchar,
				code
			FROM
				articles
			WHERE
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="statusId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				article_id::varchar,
				COUNT(article_id) OVER() AS total
			FROM
				articles
			WHERE 1=1

				<cfif !IsNull( arguments.statusId )>
					AND articles.status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND
					(
						articles.code ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
						OR articles.external_id ILIKE <cfqueryparam cfsqltype="Varchar" value="%#arguments.str#%">
					)
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

	<cffunction name="insert" returntype="String" output="false">
		<cfargument name="line" type="com.apirone.core.model.bean.Article" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO articles (
				external_id,
				status_id,
				code
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.line.getExternalId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.line.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.line.getCode()#">
			) RETURNING article_id
		</cfquery>

		<cfreturn local.q.article_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="article" type="com.apirone.core.model.bean.Article" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				articles
			SET
				external_id = <cfqueryparam cfsqltype="varchar" value="#arguments.article.getExternalId()#">,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.article.getStatus().getId()#">,
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.article.getCode()#">
			WHERE
				article_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.article.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.article.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="articleId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				articles
			WHERE
				article_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.articleId#">::uuid
			RETURNING article_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

	<!---
		Recupera in batch più articoli dato un array di ID.
	--->
	<cffunction name="readByIds" returntype="Query" access="public">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList(arguments.ids)>

		<cfquery name="local.q" datasource="apirone">
			SELECT article_id::varchar, *
			FROM articles
			WHERE article_id = ANY(
				ARRAY[<cfqueryparam value="#idsList#" list="true" cfsqltype="varchar">]::uuid[]
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>

