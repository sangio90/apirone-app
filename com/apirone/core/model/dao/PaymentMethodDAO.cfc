<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction returntype="Query" name="read">
		<cfargument name="paymentMethodId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM payment_methods
			WHERE
				payment_method_id = <cfqueryparam cfsqltype="varchar" value="#arguments.paymentMethodId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>
</cfcomponent>
