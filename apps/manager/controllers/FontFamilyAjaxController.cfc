component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var mm     = super.getMementify();
		var params = super.paramsFromUrl();

		var rows = super.fire( "fontFamily.search", params );

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
		param rc.id   = -1;
		param rc.code = "";

		var result = super.fire( "fontFamily.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result     = super.getResult();
		var fontFamily = super.bean( "FontFamily" );

		var messageId = "";
		var thisId = 0;

		var json = DeserializeJSON( GetHTTPRequestData().content );

		fontFamily.setId( json.id );
		fontFamily.setCode( json.code );
		fontFamily.setName( json.name );

		var fontFamilyId = json.id;

		if ( !Len( json.id ) ) {
			var fontFamilyId = super.service( "fontFamily" ).create( fontfamily );
			// var fontFamily = super.service("FontFamily").get( thisId );
		}

		if ( json.sizes._data.len() > 0 ) {
			var sizes = [];

			for ( var size in json.sizes._data ) {
				var fontFamilySize = super.bean( "FontFamilySize" );

				if ( size.id == "" ) {
					fontFamilySize.setId( size.id );
					fontFamilySize.setName( size.name );
					fontFamilySize.setFontFamilyId( fontFamilyId );

					super.service( "fontFamilySize" ).create( fontFamilySize );
				}
			}
		}

		if ( !Len( json.id ) ) {
			messageId = "fontFamily.created";
		} else {
			messageId = "fontFamily.updated";
			thisId    = super.fire( "fontFamily.update", [ fontfamily ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		var result = super.getResult();

		var bean = super.fire( "fontFamily.get", [ rc.id ] );

		var obj = super.getMementify().convert( bean, "detail" );

		result.setData( obj );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var content   = GetHTTPRequestData().content;
		var messageId = "fontFamily.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( content );

		for ( var id in ids ) {
			var outcome = super.fire( "fontFamily.delete", [ id ] );
			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "fontFamily.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
