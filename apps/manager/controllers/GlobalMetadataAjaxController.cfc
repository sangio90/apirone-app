component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var params = super.paramsFromUrl();

		var rows = super.fire( "metadata.search", { typeId=107 } ); // TODO: move typeId to varchar using "code"

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.append( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		param rc.id = "_";
		var result  = super.getResult();

		if ( !IsNumeric( rc.id ) ) {
			return event.setValue( "result", "No Numeric" );
		}

		var bean = super.fire( "metadataType.get", [ rc.id ] );

		var obj = super.getMementify().convert( bean, "list" );

		result.setData( obj );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result  = super.getResult();
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var bean = super.bean( "Metadata" );

		for( var thisKey in json._data ) {

			var bean = super.fire( "metadata.get", [ thisKey.id ] );

			//bean.setId( thisKey.id )
			bean.setValue( thisKey.value )

			super.fire( "metadata.update", [ bean ] );

		}

		var message = completeMessage( "globalMetadata.saved" );

		result.setData( { "message" = message }, { "payload" = { id = -1 } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "metadataType.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "metadataType.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "metadataType.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
