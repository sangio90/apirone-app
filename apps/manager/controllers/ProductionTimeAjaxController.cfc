component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var params = super.paramsFromUrl();

		var rows = super.fire( "productionTime.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( target = row, profile = "detail" );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		param rc.id = "___";

		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var row = super.fire( "productionTime.get", [ rc.id ] );

		var obj = mm.convert( target = row, profile = "detail" );

		result.setTotal( 1 );
		result.setCount( 1 );
		result.setData( obj );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId    = "";
		var messageId = "";

		var result = super.getResult();
		var bean   = super.bean( "ProductionTime" );
		var status = super.bean( "Status" );

		bean.setId( json?.id );
		bean.setName( json.name );
		bean.setStatus( status.setId( json.status.id ) );

		if ( !Len( json.id ) ) {
			messageId = "ProductionTime.created";
			thisId    = super.fire( "ProductionTime.create", [ bean ] )
		} else {
			messageId = "ProductionTime.updated";
			thisId    = super.fire( "ProductionTime.update", [ bean ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "ProductionTime.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "ProductionTime.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "ProductionTime.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
