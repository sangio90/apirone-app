component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mm = super.getMementify();

		var params = super.paramsFromUrl();

		var rows = super.fire( "country.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "country.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var result = super.getResult();

		var thisId    = "";
		var messageId = "";

		var country = super.bean( "Country" );

		country.setId( json.id );
		country.setCode( json.code );

		var nameItem        = super.buildTextBean( json.nameItem, "NAME" );
		country.setTexts( [ nameItem ] );

		if ( !Len( json.id ) ) {
			messageId = "country.created";
			thisId    = super.fire( "country.create", [ country ] )
		} else {
			messageId = "country.updated";
			thisId    = super.fire( "country.update", [ country ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "country.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "country.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "country.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}
    
}
