<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="metadataTypeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				metadata
			WHERE
				metadata_type_id = <cfqueryparam cfsqltype="Integer" value="#arguments.metadataTypeId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="readByCode" output="false">
		<cfargument name="code" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				metadata_type_id, code
			FROM
				metadata
			WHERE
				code = <cfqueryparam cfsqltype="Varchar" value="#arguments.code#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="str" type="String">
		<cfargument name="statusId" type="String">
		<cfargument name="rawValueId" type="Numeric">

		<cfargument name="limit" required="true" type="Numeric" default="20">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="code">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				metadata_type_id,
				COUNT(metadata_type_id) OVER() AS total
			FROM
				metadata
			WHERE 1=1

				<cfif !IsNull( arguments.rawValueId )>
					AND metadata.raw_value_id = <cfqueryparam cfsqltype="Integer" value="#arguments.rawValueId#">
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
		<cfargument name="metadataType" type="com.apirone.core.model.bean.MetadataType" required="true">

		<cfset var entities = super.getEntitiesAsArray( metadataType.getEntities() )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO metadata (
				code,
				metadata_type,
				status_id,
				datatype_id,
				unit_id,
				orderby,
				entities
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.metadataType.getCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.metadataType.getName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.metadataType.getStatus().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.metadataType.getDataType().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.metadataType.getMeasurementUnit().getId()#">,
				10,
				'#SerializeJSON( entities )#'
			) RETURNING metadata_type_id
		</cfquery>

		<cfreturn local.q.metadata_type_id>
	</cffunction>

	<cffunction name="update" returntype="Numeric">
		<cfargument name="metadataType" type="com.apirone.core.model.bean.MetadataType" required="true">

		<cfset var entities = super.getEntitiesAsArray( metadataType.getEntities() )>

		<cfquery name="local.q" datasource="apirone">
			UPDATE metadata
			SET
				code = <cfqueryparam cfsqltype="varchar" value="#arguments.metadataType.getCode()#">,
				metadata_type = <cfqueryparam cfsqltype="Varchar" value="#arguments.metadataType.getName()#">,
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.metadataType.getStatus().getId()#">,
				datatype_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.metadataType.getDataType().getId()#">,
				unit_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.metadataType.getMeasurementUnit().getId()#">,
				orderby = 10,
				entities = '#SerializeJSON( entities )#'
			WHERE
				metadata_type_id = <cfqueryparam cfsqltype="Integer" value="#arguments.metadataType.getId()#">
		</cfquery>

		<cfreturn arguments.metadataType.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="metadataTypeId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				metadata
			WHERE
				metadata_type_id = <cfqueryparam cfsqltype="Integer" value="#arguments.metadataTypeId#">
			RETURNING metadata_type_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>

