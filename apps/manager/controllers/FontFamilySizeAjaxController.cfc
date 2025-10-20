component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var mm     = super.getMementify();
		var params = super.paramsFromUrl();

		var rows = super.fire( "fontFamilySize.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function fontFamilyList( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var mm     = super.getMementify();
		var params = super.paramsFromUrl();

		var rows = super.fire( "fontFamilySize.search", { "fontFamilyId" = rc.id } );
		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result         = super.getResult();
		var fontFamilySize = super.bean( "FontFamilySize" );


		var thisId    = "";
		var messageId = "";

		var json = DeserializeJSON( GetHTTPRequestData().content );

		fontFamilySize.setId( json.id );
		fontFamilySize.setCode( json.code );

		if ( !Len( json.id ) ) {
			messageId = "fontFamilySize.created";
			// thisId    = super.fire( "fontfamily.create", { fontfamily = fontfamily, userId = "00001" } )

			super.service( "fontFamilySize" ).create( fontfamily );
		} else {
			messageId = "fontFamilySize.updated";
			thisId    = super.fire( "fontFamilySize.update", [ fontfamily ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		var result = super.getResult();

		var bean = super.fire( "fontFamilySize.get", [ rc.id ] );
		var obj  = super.getMementify().convert( bean, "list" );

		result.setData( obj );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var messageId = "fontFamilySize.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var fontFamilySizeId = rc.fontFamilySizeId

		var outcome = super.fire( "fontFamilySize.delete", [ fontFamilySizeId ] );

		if ( outcome.getStatus() == "ERROR" ) {
			errors.add( {
				"message" = "Non sono riuscito a cancellare l'Id #fontFamilySizeId#"
			} )
		}

		if ( errors.len() ) {
			messageId = "fontFamilySize.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
