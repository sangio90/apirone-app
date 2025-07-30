<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="profileId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
				profile_id::varchar,
				country_id::varchar,
				*
			FROM profiles
			WHERE profile_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.profileId#">::uuid
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="countryId" type="String" required="false">
		<cfargument name="type" type="String">
		<cfargument name="str" type="String" required="false">
		<cfargument name="orderBy" type="String" required="true" default="profiles.last_name, profiles.first_name">
		<cfargument name="limit" type="Numeric" required="true" default="15">
		<cfargument name="offset" type="Numeric" required="true" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				profile_id::varchar,
				country_id::varchar,
				COUNT( profile_id ) OVER() AS total
			FROM profiles
			WHERE 1=1

			<cfif !isNull( arguments.str )>
				AND (
					first_name ILIKE <cfqueryparam cfsqltype="VARCHAR" value="%#arguments.str#%">
					OR last_name ILIKE <cfqueryparam cfsqltype="VARCHAR" value="%#arguments.str#%">
				)
			</cfif>

			<cfif !IsNull( arguments.type )>
				AND type = <cfqueryparam value="#arguments.type#" cfsqltype="varchar">
			</cfif>

			<cfif !isNull(arguments.countryId)>
				AND country_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.countryId#">::uuid
			</cfif>

			ORDER BY
				#super.sanitizeSQL( arguments.orderby )#

			<cfif arguments.limit GT 0>
				LIMIT
					<cfqueryparam value="#arguments.limit#" cfsqltype="integer">
				OFFSET
					<cfqueryparam value="#arguments.offset#" cfsqltype="integer">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="profile" type="com.apirone.core.model.bean.Profile" required="true">

		<cfquery name="local.q" datasource="apirone">
			INSERT INTO profiles (
				first_name,
				last_name,
				company,
				vat_number,
				email,
				phone,
				state,
				city,
				street,
				postal_code,
				type,
				country_id
			) VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getFirstName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getLastName()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getCompany()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getVatNumber()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getEmail()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getPhone()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getState()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getCity()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getStreet()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getPostalCode()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getType().getId()#">,
				<cfqueryparam cfsqltype="Varchar" value="#arguments.profile.getCountry().getId()#">::uuid
			)
			RETURNING profile_id
		</cfquery>

		<cfreturn local.q.profile_id.toString()>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="profile" type="com.apirone.core.model.bean.Profile" required="true">
		<cfquery name="local.q" datasource="apirone">
			UPDATE profiles
			SET
				first_name = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profile.getFirstName()#">
				,
				last_name = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profile.getLastName()#">
				,
				company = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profile.getCompany()#">
				,
				vat_number = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profile.getVatNumber()#">
				,
				email = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profile.getEmail()#">
				,
				phone = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profile.getPhone()#">
				,
				country_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profile.getCountry().getId()#">::uuid
				,
				state = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profile.getState()#">
				,
				city = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profile.getCity()#">
				,
				postal_code = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profile.getPostalCode()#">
				,
				type = <cfqueryparam cfsqltype="CHAR" value="#arguments.profile.getType().getId()#">
				,
				street = <cfqueryparam cfsqltype="TEXT" value="#arguments.profile.getStreet()#">

			WHERE 
				profile_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profile.getId()#">::uuid
		</cfquery>

		<cfreturn arguments.profile.getId()>
	</cffunction>


	<cffunction name="delete" returntype="Boolean">
		<cfargument name="profileId" type="String" required="true">

		<cfquery name="local.q" datasource="apirone">
			DELETE FROM profiles
			WHERE profile_id = <cfqueryparam cfsqltype="VARCHAR" value="#arguments.profileId#">::uuid
		</cfquery>

		<cfreturn true>
	</cffunction>
</cfcomponent>