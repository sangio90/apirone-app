<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="currencyId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM currencies
			WHERE 
				<cfif !isNull(arguments.paymentMethodId)>
					currency_id = <cfqueryparam cfsqltype="varchar" value="#arguments.currencyId#">::uuid
				<cfelse>
					1=1
				</cfif>
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>