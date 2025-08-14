component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var dm     = super.getDataMapper();
		var params = super.paramsFromUrl();

		var rows = super.fire( "font.search", params );

		for ( var row in rows.getData() ) {
			var obj = dm.convert( row, "Font", true );
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

		var result = super.fire( "font.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result = super.getResult();
		var font   = super.bean( "Font" );
		var text   = super.bean( "Text" );
		var lang   = super.bean( "Lang" );


		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var json = DeserializeJSON( GetHTTPRequestData().content );

		font.setId( json.id );
		font.setCode( json.code );
		font.setDimension( json.dimension );
		font.setDirectory( "#LCase( json.code )#" );
		font.setFamily( json.family );

		text.setId( json.nameItem.id );
		text.setName( json.nameItem.name );
		text.setLang( lang.setId( json.nameItem.lang.id, "IT" ) );
		texts.add( text );

		font.setTexts( texts );

		if ( !Len( json.id ) ) {
			messageId = "font.created";
			// thisId    = super.fire( "font.create", { font = font, userId = "00001" } )

			super.service( "font" ).create( font );
		} else {
			messageId = "font.updated";
			thisId    = super.fire( "font.update", [ font ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		var result = super.getResult();

		var bean = super.fire( "font.get", [ rc.id ] );

		var obj = super.getDataMapper().convert( bean, "Font", true );

		result.setData( obj );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var content   = GetHTTPRequestData().content;
		var messageId = "font.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( content );

		for ( var id in ids ) {
			var outcome = super.fire( "font.delete", [ id ] );
			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "font.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
