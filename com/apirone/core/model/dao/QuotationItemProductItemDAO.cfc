<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
    <cffunction name="read" returntype="Query">
        <cfargument name="productItemId" type="String" required="true">
        <cfquery name="local.q" datasource="apirone">
            SELECT
                quotation_item_product_item_id::varchar,
                quotation_item_product_id::varchar,
                product_item_id::integer,
                parent_id::varchar,
                *
            FROM quotation_item_product_items
            WHERE quotation_item_product_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItemId#">::uuid
        </cfquery>
        <cfreturn local.q>
    </cffunction>

    <cffunction name="find" returntype="Query">
        <cfargument name="quotationItemProductId" type="String" required="false">
        <cfargument name="productItemId" type="String" required="false">
        <cfargument name="parentId" type="String" required="false">
        <cfargument name="orderBy" type="String" required="true" default="quotation_item_product_item_id">
        <cfargument name="limit" type="Numeric" required="true" default="15">
        <cfargument name="offset" type="Numeric" required="true" default="0">
        <cfquery name="local.q" datasource="apirone" result="result">
            SELECT
                quotation_item_product_item_id::varchar,
                quotation_item_product_id::varchar,
                product_item_id::integer,
                parent_id::varchar,
                COUNT(quotation_item_product_item_id) OVER() AS total
            FROM 
                quotation_item_product_items
            WHERE 1=1
                <cfif !isNull( arguments.quotationItemProductId )>
                    AND quotation_item_product_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.quotationItemProductId#">::uuid
                </cfif>
                <cfif !isNull( arguments.productItemId )>
                    AND product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItemId#">
                </cfif>
                <cfif !isNull( arguments.parentId )>
                    AND parent_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.parentId#">::uuid
                </cfif>
            ORDER BY #super.sanitizeSQL( arguments.orderB )#

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
                quotation_item_product_id,
                product_item_id,
                parent_id
            ) VALUES (
                <cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getQuotationItemProduct().getId()#">::uuid,
                <cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getProductItem().getId()#">,
                <cfif !IsNull( arguments.productItem.getParent() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getParent().getId()#">::uuid
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
            UPDATE quotation_item_product_items
            SET
                quotation_item_product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getQuotationItemProduct().getId()#">::uuid,
                product_item_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productItem.getProductItem().getId()#">
                <cfif !IsNull( arguments.productItem.getParent() )>
					,parent_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getParent().getId()#">::uuid
				</cfif>
            WHERE quotation_item_product_item_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productItem.getId()#">::uuid
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
</cfcomponent>
