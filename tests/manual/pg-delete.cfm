<cfoutput>

	<cftransaction>

		<cfset to = 10>
<cfoutput>
records: #to#
</cfoutput>

		<cfloop from=1 to="#to#" index="i">
			
			<cfquery name="q" datasource="apirone">
				INSERT INTO _tbl1 (f1, f2)
				VALUES ( #i#, #i*5# ) RETURNING f1, f2
			</cfquery>

		</cfloop>

	</cftransaction>

	<cfquery name="q" datasource="apirone" result="result">
		SELECT * FROM _tbl1
	</cfquery>	

	<cfdump var="#q#">

	<cfquery name="q" datasource="apirone" result="result">
		DELETE FROM _tbl1
		WHERE f1::integer < 20
		RETURNING *
	</cfquery>

	<cfdump var="#result#">

</cfoutput>

