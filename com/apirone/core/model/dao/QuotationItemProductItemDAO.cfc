<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">
		<cfargument name="productItemId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_product_item_id::varchar,
				quotation_item_id::varchar,
				*
			FROM quotation_item_product_items
			WHERE quotation_item_product_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItemId#">::uuid
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<!---
		Recupera in batch più record dato un array di ID.
		Utilizzato dal Service corrispondente per caricare i bean in blocco.
	--->
	<cffunction name="readByIds" returntype="Query">
		<cfargument name="ids" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.ids )>

		<cfquery name="local.q" datasource="apirone">
			SELECT
				quotation_item_product_item_id::varchar,
				quotation_item_id::varchar,
				*
			FROM quotation_item_product_items
			WHERE quotation_item_product_item_id::varchar IN ( <cfqueryparam value="#idsList#" list="true" cfsqltype="varchar"> )
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="quotationItemId" type="String" required="false">
		<cfargument name="productItemId" type="String" required="false">
		<cfargument name="originId" type="String" required="false">
		<cfargument name="orderBy" type="String" required="true" default="quotation_item_product_item_id">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				quotation_item_product_item_id::varchar,
				quotation_item_id::varchar,
				product_item_id,
				origin_id::varchar,
				"level",
				COUNT(quotation_item_product_item_id) OVER() AS total
			FROM
				quotation_item_product_items
			WHERE 1=1

				<cfif !IsNull( arguments.quotationItemFruitId )>
					AND quotation_item_fruit_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruitId#">
				</cfif>

				<cfif !IsNull( arguments.quotationItemId )>
					AND quotation_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.quotationItemId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.productItemId )>
					AND product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
				</cfif>

				<cfif !IsNull( arguments.originId )>
					AND origin_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.originId#">
				</cfif>
			ORDER BY
				#super.sanitizeSQL( arguments.orderBy )#

			<cfif arguments.limit GT 0>
				LIMIT <cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>
		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="productItem" type="com.apirone.core.model.bean.QuotationItemProductItem" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO quotation_item_product_items (
				quotation_item_id,
				quotation_item_fruit_id,
				origin_id,
				product_item_id,
				level,
				note
			) VALUES (

				<cfif !IsNull( arguments.productItem.getQuotationItemId() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getQuotationItemId()#">::uuid
				<cfelse>
					NULL
				</cfif>,

				<cfif !IsNull( arguments.productItem.getQuotationItemFruitId() )>
					<cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getQuotationItemFruitId()#">
				<cfelse>
					NULL
				</cfif>,

				<cfif !IsNull( arguments.productItem.getOrigin() )>
					<cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getOrigin().getId()#">
				<cfelse>
					NULL
				</cfif>,

				<cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getProductItem().getId()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getLevel()#">,

				<cfif !IsNull( arguments.productItem.getNote() )>
					<cfqueryparam cfsqltype="Text" value="#arguments.productItem.getNote()#">
				<cfelse>
					NULL
				</cfif>
			)
			RETURNING quotation_item_product_item_id
		</cfquery>
		<cfreturn local.q.quotation_item_product_item_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="productItem" type="com.apirone.core.model.bean.QuotationItemProductItem" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE
				quotation_item_product_items
			SET
				product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getProductItem().getId()#">,
				level = <cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getLevel()#">,

				quotation_item_id =
					<cfif !IsNull( arguments.productItem.getQuotationItemId() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getQuotationItemId()#">::uuid
					<cfelse>
						NULL
					</cfif>,

				quotation_item_fruit_id =
					<cfif !IsNull( arguments.productItem.getQuotationItemFruitId() )>
						<cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getQuotationItemFruitId()#">
					<cfelse>
						NULL
					</cfif>,

				origin_id =
					<cfif !IsNull( arguments.productItem.getOrigin() )>
						<cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getOrigin().getId()#">
					<cfelse>
						NULL
					</cfif>,

				note =
					<cfif !IsNull( arguments.productItem.getNote() )>
						<cfqueryparam cfsqltype="Text" value="#arguments.productItem.getNote()#">
					<cfelse>
						NULL
					</cfif>
			WHERE
				quotation_item_product_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getId()#">::uuid
		</cfquery>
		<cfreturn arguments.productItem.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="productItemId" type="String" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				quotation_item_product_items
			WHERE
				quotation_item_product_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItemId#">::uuid
		</cfquery>
		<cfreturn true>
	</cffunction>

	<cffunction name="deleteByQuotationItemFruitId" returntype="Boolean">
		<cfargument name="quotationItemFruitId" type="Numeric" required="true">
		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				quotation_item_product_items
			WHERE
				quotation_item_fruit_id = <cfqueryparam cfsqltype="Integer" value="#arguments.quotationItemFruitId#">
		</cfquery>
		<cfreturn true>
	</cffunction>

	<!---
		Recupera in batch i QIPI collegati a più quotation_item_id.
		Utilizzato da QuotationItemService.getMany() per evitare N+1.
	--->
	<cffunction name="readByQuotationItemIds" returntype="Query" access="public">
		<cfargument name="quotationItemIds" type="Array" required="true">

		<cfset var idsList = ArrayToList( arguments.quotationItemIds )>

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM quotation_item_product_items
			WHERE quotation_item_id::varchar IN (
				<cfqueryparam value="#idsList#" list="true" cfsqltype="varchar">
			)
		</cfquery>

		<cfreturn local.q>
	</cffunction>

</cfcomponent>
