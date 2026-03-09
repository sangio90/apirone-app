<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="productHashId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				product_hashes
			WHERE
				product_hash_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productHashId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="hash" type="String">
		<cfargument name="productHashId" type="Numeric">
		<cfargument name="jsonData" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="20">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="product_hash_id">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				product_hash_id,
				COUNT(product_hash_id) OVER() AS total
			FROM
				product_hashes
			WHERE 1=1
				<cfif !IsNull( arguments.hash )>
					AND hash = <cfqueryparam cfsqltype="Varchar" value="#arguments.hash#">
				</cfif>

				<cfif !IsNull( arguments.productHashId )>
					AND product_hash_id = <cfqueryparam cfsqltype="Integer" value="#arguments.productHashId#">
				</cfif>

				<cfif !IsNull( arguments.jsonData )>
					AND json_data = <cfqueryparam cfsqltype="Varchar" value="#arguments.jsonData#">
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

	<cffunction name="insert" returntype="Numeric" output="false">
		<cfargument name="ProductHash" type="com.apirone.core.model.bean.ProductHash" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO product_hashes (
				hash,
				json_data
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.ProductHash.getHash()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.ProductHash.getJsonData()#">
			) RETURNING product_hash_id
		</cfquery>

		<cfreturn local.q.product_hash_id>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="ProductHashId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				product_hashes
			WHERE
				product_hash_id = <cfqueryparam cfsqltype="Integer" value="#arguments.ProductHashId#">
			RETURNING signage_config_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>

