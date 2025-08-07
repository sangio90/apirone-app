<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction returntype="Query" name="read">
		<cfargument name="paymentMethodId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM payment_methods
			WHERE
				<cfif !IsNull( arguments.paymentMethodId )>
					payment_method_id = <cfqueryparam cfsqltype="varchar" value="#arguments.paymentMethodId#">::uuid
				<cfelse>
					1=1
				</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
