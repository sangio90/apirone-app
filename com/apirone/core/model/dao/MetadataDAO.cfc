<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="metadataTypeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				metadata
			WHERE
				metadata_id = <cfqueryparam cfsqltype="Integer" value="#arguments.metadataTypeId#">
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
				metadata_id,
				COUNT(metadata_id) OVER() AS total
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

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="metadata" type="com.apirone.core.model.bean.Metadata" required="true">

		<cfset var meta = getFieldsAndValues( arguments.metadata.getEntity() )>
		<cfset var dataType = arguments.metadata.getDataTypeId()>

		<cfset var field = getFieldByDataType( dataType )>

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO metadata (
				metadata_type_id,
				#field#,
				#ArrayToList( meta.fields )#
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.metadata.getType().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.metadata.getValue()#">,

				<cfloop array="#meta.values#" item="item" index="index">
					<cfqueryparam cfsqltype="#item.type#" value="#item.value#">
					<cfif Len( meta.values ) NEQ index>
						,
					</cfif>
				</cfloop>
			) RETURNING metadata_id
		</cfquery>

		<cfreturn local.q.metadata_id>
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
				metadata_id = <cfqueryparam cfsqltype="Integer" value="#arguments.metadataType.getId()#">
		</cfquery>

		<cfreturn arguments.metadataType.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="metadataTypeId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				metadata
			WHERE
				metadata_id = <cfqueryparam cfsqltype="Integer" value="#arguments.metadataTypeId#">
			RETURNING metadata_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>

	<!--- private methods --->

	<cffunction name="getFieldsAndValues" returntype="Struct" access="private">
		<cfargument name="entity" type="com.apirone.core.model.bean.Entity" required="true">

		<cfset var fields = []>
		<cfset var values = []>

		<cfswitch expression="#entity.getKey()#">
			<cfcase value="rawValue.id">
				<cfset fields = [ "raw_value_id" ]>
				<cfset values = [ { value = entity.getValue(), type = "Integer" } ]>
			</cfcase>

			<cfdefaultcase>
				<cfthrow type="apirone.error.metadata.EntityNotValid" message="Entity [#entity.getKey()#] not valid">
			</cfdefaultcase>
		</cfswitch>

		<cfreturn { "fields" = fields, "values" = values }>
	</cffunction>

	<cffunction name="getFieldByDataType" returntype="String" access="private">
		<cfargument name="dataType" type="String" required="true">

		<cfset var list = DeserializeJSON( FileRead( ExpandPath( "/config/data/dataTypes.json.cfm" ) ) )>

		<cfloop array="#list#" index="item">
			<cfif item.id eq arguments.dataType>
				<cfreturn item.field>
			</cfif>
		</cfloop>

		<cfthrow
			type   ="apirone.error.FieldNotFoundByDatatype"
			message="The field for [#dataType#] dataType not found"
		>
	</cffunction>
</cfcomponent>
