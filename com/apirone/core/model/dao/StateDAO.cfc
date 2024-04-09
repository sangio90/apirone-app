<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">

	<cffunction returntype="Query" name="read">

		<cfargument name="stateId" type="String" required="true">

		<cfquery name="local.q" datasource="zerobenefit">
			SELECT *
			FROM states
			WHERE state_id = <cfqueryparam cfsqltype="varchar" value="#arguments.stateId#">::uuid
		</cfquery>

		<cfreturn local.q>

	</cffunction>

</cfcomponent>