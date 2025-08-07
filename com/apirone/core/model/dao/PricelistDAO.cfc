<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction returntype="Query" name="read">
		<cfargument name="pricelistId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM pricelists
			WHERE
				<cfif !IsNull( arguments.paymentMethodId )>
					pricelist_id = <cfqueryparam cfsqltype="varchar" value="#arguments.pricelistId#">::uuid
				<cfelse>
					1=1
				</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
