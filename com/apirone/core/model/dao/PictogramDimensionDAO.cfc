<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read">
		<cfargument name="pictogramDimensionId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				*
			FROM
				pictogram_dimensions
			WHERE
				pictogram_dimension_id = <cfqueryparam cfsqltype="Integer" value="#arguments.pictogramDimensionId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="pictogramId" type="Numeric">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				pictogram_dimension_id,
				COUNT(pictogram_id) OVER() AS total
			FROM
				pictogram_dimensions
			WHERE 1=1
				<cfif !IsNull( arguments.pictogramId )>
					AND pictogram_id = <cfqueryparam cfsqltype="Integer" value="#arguments.pictogramId#">
				</cfif>
			ORDER BY
				pictogram_id
		</cfquery>

		<cfreturn local.q>
	</cffunction>	

	<cffunction name="insert" returntype="Numeric">
		<cfargument name="pictogramDimension" type="com.apirone.core.model.bean.PictogramDimension" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO pictogram_dimensions (
				width,
				height,
				pictogram_id,
				font_family_size_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Integer" value="#arguments.pictogramDimension.getWidth()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.pictogramDimension.getHeight()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.pictogramDimension.getPictogramId()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.pictogramDimension.getFontFamilySizeId()#">
			) RETURNING pictogram_dimension_id
		</cfquery>

		<cfreturn local.q.pictogram_dimension_id>
	</cffunction>

	<cffunction name="update" returntype="Numeric">
		<cfargument name="pictogramDimension" type="com.apirone.core.model.bean.PictogramDimension" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE pictogram_dimensions 
			SET
				width = <cfqueryparam cfsqltype="Integer" value="#arguments.pictogramDimension.getWidth()#">,
				height = <cfqueryparam cfsqltype="Integer" value="#arguments.pictogramDimension.getHeight()#">
			WHERE
				pictogram_dimension_id = <cfqueryparam cfsqltype="Integer" value="#arguments.pictogramDimension.getId()#">
		</cfquery>

		<cfreturn arguments.pictogramDimension.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Numeric">
		<cfargument name="pictogramDimensionId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM
				pictogram_dimensions
			WHERE
				pictogram_dimension_id = <cfqueryparam cfsqltype="Integer" value="#arguments.pictogramDimensionId#">
			RETURNING pictogram_dimension_id
		</cfquery>

		<cfreturn local.q.recordCount>
	</cffunction>
</cfcomponent>
