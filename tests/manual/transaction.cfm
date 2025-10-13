<cfoutput>

	<cfquery name="q" datasource="apirone">
		INSERT INTO _tbl1 (code)
		VALUES ( #RandRange( 1,20000 )# ) RETURNING id
	</cfquery>

	<cfquery name="x" datasource="apirone">
		INSERT INTO _tbl2 ( code )
		VALUES ( #q.id# )
	</cfquery>

</cfoutput>