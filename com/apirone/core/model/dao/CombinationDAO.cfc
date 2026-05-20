<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="combinationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			    combination_id::varchar,
    			product_id::varchar,
	    		*
			FROM
		    	combinations
			WHERE
			    combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find">
		<cfargument name="productId" type="String" required="true">
		<cfargument name="statusId" type="String">
		<cfargument name="str" type="String">
		<cfargument name="orderby" required="true" type="String" default="product.product_id">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			    combination_id::varchar,
				COUNT(combination_id) OVER() AS total
			FROM
    			combinations
			WHERE
	    		product_id = <cfqueryparam cfsqltype="varchar" value="#arguments.productId#">::uuid

				<cfif !IsNull( arguments.statusId )>
					AND status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.statusId#">
				</cfif>

				<cfif !IsNull( arguments.str )>
					AND #super.createOrConditions( arguments.str, "combination" )#
				</cfif>

			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="findByListOfProductItemIds" access="public">
		<cfargument name="productItemIds" type="array" required="true">

		<cfset var idsList = arrayToList(arguments.productItemIds)>
		<cfset var q = "">

		<cfquery name="q" datasource="apirone">
			WITH
			-- Coppie (attribute_id, product_item_id) risolte dagli ID
			-- ricevuti nella richiesta corrente.
			-- Servono per il controllo dei conflitti: se una combinazione ha un
			-- valore diverso per lo stesso attributo, viene esclusa.
			selected_attrs AS (
			    SELECT arv.attribute_id, pi.product_item_id
			    FROM product_items pi
			    INNER JOIN attributes_raw_values arv ON arv.attribute_raw_value_id = pi.attribute_raw_value_id
			    WHERE pi.product_item_id IN (
			        <cfqueryparam value="#idsList#" list="true" cfsqltype="cf_sql_integer">
			    )
			),
			-- Coppie (combination_id, attribute_id, product_item_id) per TUTTE le
			-- combinazioni esistenti. Viene usata sia per trovare i conflitti sia per
			-- costruire le candidate.
			combination_attrs AS (
			    SELECT cpi.combination_id, arv.attribute_id, pi.product_item_id
			    FROM combination_product_items cpi
			    INNER JOIN product_items pi ON pi.product_item_id = cpi.product_item_id
			    INNER JOIN attributes_raw_values arv ON arv.attribute_raw_value_id = pi.attribute_raw_value_id
			),
			-- Combinazioni candidate: hanno almeno un product_item_id tra quelli
			-- selezionati. Il DISTINCT evita duplicati se la combinazione matcha
			-- più di un item.
			candidates AS (
			    SELECT DISTINCT combination_id
			    FROM combination_product_items
			    WHERE product_item_id IN (
			        <cfqueryparam value="#idsList#" list="true" cfsqltype="cf_sql_integer">
			    )
			),
			-- Combinazioni in conflitto: tra le candidate, quelle che hanno almeno
			-- un attributo con un valore DIVERSO da quello selezionato dall'utente.
			-- Esempio: combinazione ha Incisione="SI" ma l'utente ha scelto Incisione="NO".
			conflicts AS (
			    SELECT ca.combination_id
			    FROM combination_attrs ca
			    INNER JOIN selected_attrs sa
			        ON sa.attribute_id = ca.attribute_id
			        AND sa.product_item_id != ca.product_item_id
			    WHERE ca.combination_id IN (SELECT combination_id FROM candidates)
			)
			-- Restituisce solo le candidate che NON hanno conflitti
			SELECT combination_id::varchar
			FROM candidates
			WHERE combination_id NOT IN (SELECT combination_id FROM conflicts)
		</cfquery>

		<cfreturn q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="combination" type="com.apirone.core.model.bean.Combination" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO combinations (
				combination,
	    		product_id,
		    	status_id
			)
			VALUES (
			    <cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getName()#">,
			    <cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getProductId()#">::uuid,
    			<cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getStatus().getId()#">
			) RETURNING combination_id
		</cfquery>

		<cfreturn local.q.combination_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="combination" type="com.apirone.core.model.bean.Combination" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				combinations
			SET
				combination = <cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getName()#">
			WHERE
				combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combination.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.combination.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="combinationId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
            FROM
                combinations
			WHERE
		    	combination_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.combinationId#">::uuid
		</cfquery>

		<cfreturn true>
	</cffunction>
</cfcomponent>
