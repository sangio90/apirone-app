component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		param rc.customerId = "";

		var result = super.getResult();

		if ( !Len( rc.customerId ) ) {
			result.setStatus( "ERROR" );
			result.setData( { "message" = "customerId is required", "type" = "MissingParameter" } );
			event.setValue( "result", result );
			return;
		}

		var siteMain = server.system.properties[ "site.main" ] ?: "";

		var q = queryExecute(
			"SELECT CAST(quotation_id AS varchar) AS quotation_id,
			        quotation_number,
			        version_number,
			        quotation,
			        quotation_date
			 FROM quotations
			 WHERE customer_id = CAST(? AS UUID)
			 ORDER BY quotation_number DESC, version_number DESC",
			[ { value: rc.customerId, cfsqltype: "CF_SQL_VARCHAR" } ],
			{ datasource: "apirone" }
		);

		var rows = [];
		for ( var row in q ) {
			ArrayAppend( rows, {
				"id":               row.quotation_id,
				"quotation_number": row.quotation_number,
				"version_number":   row.version_number,
				"quotation":        row.quotation,
				"quotation_date":   ( !IsNull( row.quotation_date ) && IsDate( row.quotation_date ) ) ? DateFormat( row.quotation_date, "yyyy-mm-dd" ) : "",
				"url":              "#siteMain#/manager/quotations/#row.quotation_id#"
			} );
		}

		result.setData( rows );
		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		event.setValue( "result", result );
	}

}
