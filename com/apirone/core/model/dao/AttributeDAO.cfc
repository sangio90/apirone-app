<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cfset variables.companyId = "azapi">

	<cffunction name="read">

		<cfargument name="typeId" type="String" required="true">
		<cfargument name="attributeId" type="String" required="true">

		<cfquery name="local.q" datasource="verticale">
			SELECT *
			FROM
				#variables.companyId#_colori
			WHERE
				clcodice = <cfqueryparam cfsqltype="varchar" value="#arguments.attributeId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>
	
	<!----
		artiplav = lav = lavorazioni
		a = materia prima
		m = prodotto finito
		s = semilavorato
	---->

	<cffunction returntype="Query" name="find">

		<cfargument name="typeId" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="arcodart">
		
        <cfquery name="local.q" datasource="verticale">
			SELECT
				arcodart, ardesart,
				COUNT(arcodart) OVER() AS total
			FROM
				#super.sanitizeSQL( "#variables.companyId#_artico" )# a
			WHERE 1=1
			
			<cfif !isNull( arguments.typeId )>
				AND codtip = <cfqueryparam value="#arguments.typeId#" cfsqltype="varchar">
			</cfif>
			
			<cfif !isNull( arguments.processingTypeId )>
				AND arsemlav = <cfqueryparam value="#arguments.processingTypeId#" cfsqltype="varchar">
			</cfif>
                
			ORDER BY 
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				OFFSET <cfqueryparam value="#arguments.offset#" cfsqltype="integer"> ROWS
				FETCH NEXT <cfqueryparam value="#arguments.limit#" cfsqltype="integer"> ROWS ONLY;
			</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>	

</cfcomponent>