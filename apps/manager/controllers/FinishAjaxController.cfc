component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();

		var dm = getDataMapper();

		var params = super.paramsFromUrl( "finish" );

		var rows = super.fire( "finish.list", params );

		for ( var row in rows ) {
			var obj = dm.convert( row, "Finish", true );
			data.add( obj );
		}

		result.setTotal( data.len() );
		result.setCount( data.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "finish.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result     = super.getResult();
		var finish     = super.bean( "Finish" );
		var status     = super.bean( "Status" );
		var categories = [];

		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var json = DeserializeJSON( getHTTPRequestData().content );

		finish.setId( json.id );
		finish.setCode( json.code );

		for ( var thisCategory in json.selectedCategories ) {

			var category   = super.bean( "ProductCategory" );

			category.setId( thisCategory.id );
			categories.add( category );
		}

		finish.setCategories( categories );
		finish.setStatus( status.setId( json.status.id ) );

		var text = super.bean("Text");
		var lang = super.bean("Lang");

		text.setName( json.name )
		text.setLang( lang.setId( "IT" ) ); //FIXME: this, get lang from json

		texts.add( text );

		finish.setTexts( texts );

		if ( !len( json.id ) ) {
			messageId = "finish.created";
			thisId    = super.fire( "finish.create", [ finish ] )
		} else {
			messageId = "finish.updated";
			thisId    = super.fire( "finish.update", [ finish ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

}
