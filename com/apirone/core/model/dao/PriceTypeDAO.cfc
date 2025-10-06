<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction returntype="Query" name="read">
		<cfargument name="priceTypeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT entities::varchar, methods::varchar, *
			FROM price_types
			WHERE price_type_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.priceTypeId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="entityId" type="String">
		<cfargument name="methodId" type="String">
		<cfargument name="statusId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="50">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				price_type_id,
				COUNT(price_type_id) OVER() AS total
			FROM
				price_types
			WHERE 1=1

			<cfif !IsNull( arguments.entityId )>
				AND jsonb_exists( entities, <cfqueryparam value="#UCase( arguments.entityId )#" cfsqltype="Varchar"> )
			</cfif>

			<cfif !IsNull( arguments.methodId )>
				AND jsonb_exists( methods, <cfqueryparam value="#UCase( arguments.methodId )#" cfsqltype="Varchar"> )
			</cfif>

			<cfif !IsNull( arguments.str )>
				AND price_type ILIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
			</cfif>

			<cfif !IsNull( arguments.statusId )>
				AND status_id = <cfqueryparam value="#arguments.statusId#" cfsqltype="varchar">
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
		<cfargument name="priceType" type="com.apirone.core.model.bean.PriceType" required="true">

		<cfset var methods = super.getMethodsAsArray( priceType.getMethods() )>
		<cfset var entities = super.getEntitiesAsArray( priceType.getEntities() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO price_types(
				price_type_id,
				price_type,
				status_id,
				methods,
				entities
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.priceType.getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.priceType.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.priceType.getStatus().getId()#">,
				'#SerializeJSON( methods )#',
				'#SerializeJSON( entities )#'
			) RETURNING price_type_id
		</cfquery>

		<cfreturn q.price_type_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="priceType" type="com.apirone.core.model.bean.PriceType" required="true">

		<cfset var methods = super.getMethodsAsArray( priceType.getMethods() )>
		<cfset var entities = super.getEntitiesAsArray( priceType.getEntities() )>

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				price_types
			SET
				price_type = <cfqueryparam cfsqltype="Varchar" value="#arguments.priceType.getName()#">,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.priceType.getStatus().getId()#">,
				methods = '#SerializeJSON( methods )#',
				entities = '#SerializeJSON( entities )#'
			WHERE 
				price_type_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.priceType.getId()#">
		</cfquery>

		<cfreturn arguments.priceType.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="priceTypeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM price_types
			WHERE
				price_type_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.priceTypeId#">
		</cfquery>

		<cfreturn true>
	</cffunction>

</cfcomponent>
