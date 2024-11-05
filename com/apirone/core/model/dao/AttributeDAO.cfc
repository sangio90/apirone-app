<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction name="read" returntype="Query">

		<cfargument name="attributeId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				attributes
			WHERE
				attribute_id = <cfqueryparam cfsqltype="varchar" value="#arguments.attributeId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="find" returntype="Query">

		<cfargument name="str" type="String">

        <cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM
				attributes
					<cfif !IsNull( arguments.str )>
						INNER JOIN texts USING ( attribute_id )
					</cfif>
			WHERE 1=1
				<cfif !IsNull( arguments.str )>
					AND texts.text ILIKE <cfqueryparam cfsqltype="varchar" value="#arguments.str#%">
				</cfif>
            ORDER BY 
                attribute_id
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	<cffunction name="insert" returntype="String">

		<cfargument name="attribute" type="com.apirone.core.model.bean.Attribute" required="true">

        <cfquery name="local.q" datasource="apirone">
			INSERT INTO attributes (
				attribute_id,
				status_id
			)
			VALUES (
				<cfqueryparam cfsqltype="varchar" value="#arguments.attribute.getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.attribute.getStatus().getId()#">
			)
		</cfquery>

		<cfreturn arguments.attribute.getId()>

	</cffunction>


	<cffunction name="update" returntype="String">

		<cfargument name="attribute" type="com.apirone.core.model.bean.Attribute" required="true">

        <cfquery name="local.q" datasource="apirone">
			UPDATE 
				attributes 
			SET 
				status_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attribute.getStatus().getId()#">
			WHERE
				attribute_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.attribute.getId()#">
		</cfquery>

		<cfreturn arguments.attribute.getId()>

	</cffunction>

</cfcomponent>