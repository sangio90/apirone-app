component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var mm     = super.getMementify();
		var params = super.paramsFromUrl();

		var rows = super.fire( "pictogram.search", params );
		
		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function fontFamilyExists( event, rc, prc ){
		param rc.id   = -1;
		param rc.code = "";
		param rc.fontFamilyId = -1;

		var result = super.fire( "pictogram.fontFamilyExists", { code = rc.code, fontFamilyId = rc.fontFamilyId, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result = super.getResult();
		var pictogram   = super.bean( "Pictogram" );
		var fontFamily   = super.bean( "FontFamily" );
		var text   = super.bean( "Text" );
		var lang   = super.bean( "Lang" );


		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var json = DeserializeJSON( GetHTTPRequestData().content );

		pictogram.setId( json.id );
		pictogram.setCode( json.code );
		pictogram.setFontFamily( fontFamily.setId( json.fontFamily.id ) );

		var text = super.buildTextBean( json.nameItem, "NAME" );

		texts.add( text );

		pictogram.setTexts( texts );

		if ( !Len( json.id ) ) {
			messageId = "pictogram.created";
			// thisId    = super.fire( "pictogram.create", { pictogram = pictogram, userId = "00001" } )

			super.service( "pictogram" ).create( pictogram );
		} else {
			messageId = "pictogram.updated";
			thisId    = super.fire( "pictogram.update", [ pictogram ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		var result = super.getResult();

		var bean = super.fire( "pictogram.get", [ rc.id ] );
		var obj  = super.getMementify().convert( bean, "list" );

		result.setData( obj );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var content   = GetHTTPRequestData().content;
		var messageId = "pictogram.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( content );

		for ( var id in ids ) {
			var outcome = super.fire( "pictogram.delete", [ id ] );
			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "pictogram.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
