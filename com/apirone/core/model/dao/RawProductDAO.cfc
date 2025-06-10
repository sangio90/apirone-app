<cfcomponent extends="com.apirone.core.model.dao.VerticaleDAO" accessors="true">

	<cffunction name="read">

		<cfargument name="rawProductId" type="String" required="true">

		<cfquery name="local.q" datasource="verticale">

			SELECT
				arcodart, 
				arsemlav, 
				artipmat, 
				arcodart, 
				ardesart, 
				artipmat,
				arunmis1,
				IIF (artipmat = 'LAV', 'LV', 'MP') AS processiong_type_id
			FROM
				#variables.companyId#_artico a
			WHERE
				arcodart = <cfqueryparam cfsqltype="varchar" value="#arguments.rawProductId#">
		</cfquery>

		<cfreturn local.q>

	</cffunction>

	
	<!----
		a = materia prima
		m = prodotto finito
		s = semilavorato

		artiplav = lav = lavorazioni
	---->

	<cffunction returntype="Query" name="find">

		<cfargument name="typeId" type="String">
		<cfargument name="processingTypeId" type="String">
		<cfargument name="str" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
        <cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="arcodart">

        <cfquery name="local.q" datasource="verticale">
			SELECT
				arcodart, 
				ardesart,
				arsemlav,
				artipmat,
				arunmis1,
				COUNT(arcodart) OVER() AS total,
				IIF (artipmat = 'LAV', 'LV', 'MT') AS processiong_type_id
			FROM
				#super.sanitizeSQL( "#variables.companyId#_artico" )# artico
			WHERE 1=1
				AND arobsole <> 'S' 
			
			<cfif !isNull( arguments.typeId )>
				AND codtip = <cfqueryparam value="#arguments.typeId#" cfsqltype="varchar">
			</cfif>

			<!--- lavorazioni --->
			<cfif arguments.processingTypeId == "LV">
				AND artipmat = 'LAV'
			</cfif>
			
			<!--- materie prime --->
			<cfif arguments.processingTypeId == "MP">
				AND arsemlav = 'A' AND artipmat <> 'LAV'
			</cfif>
                
			<cfif !isNull( arguments.str )>
				AND ( 
						ardesart LIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
						OR arcodart LIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
					)
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