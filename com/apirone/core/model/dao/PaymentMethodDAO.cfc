<cfcomponent extends="com.apirone.core.model.dao.VerticaleDAO" accessors="true">
	<cffunction returntype="Query" name="read">
		<cfargument name="paymentMethodId" type="String" required="true">

		<cfif !request.loadFromVerticale>
			<cfreturn getMockedPaymentMethod( arguments.paymentMethodId )>
		</cfif>

		<cfquery name="local.q" datasource="verticale">
			SELECT
				pagcod AS payment_method_id,
				pagdes AS payment_method
			FROM
				codpag
			WHERE
				pagcod = <cfqueryparam cfsqltype="Integer" value="#arguments.paymentMethodId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction returntype="Query" name="find">
		<cfargument name="str" type="String">

		<cfargument name="limit" required="true" type="Numeric" default="0">
		<cfargument name="offset" required="true" type="Numeric" default="0">
		<cfargument name="orderby" required="true" type="String" default="pagdes">

		<cfif !request.loadFromVerticale>
			<cfreturn listMockedPaymentMethod()>
		</cfif>

		<cfquery name="local.q" datasource="verticale">
			SELECT
				pagcod AS payment_method_id,
				pagdes AS payment_method,
				COUNT(pagcod) OVER() AS total
			FROM
				codpag
			WHERE 1=1

			<cfif !IsNull( arguments.str )>
				AND (
						pagdes LIKE <cfqueryparam value="%#arguments.str#%" cfsqltype="varchar">
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
