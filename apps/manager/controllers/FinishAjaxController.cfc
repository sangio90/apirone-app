component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();

		var mm = super.getMementify();

		var params = super.paramsFromUrl();

		// params[ "orderBy" ] = [ { field = "finish.code" } ];

		var rows = super.fire( "finish.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
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
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var result = super.getResult();

		var categories = [];

		var thisId    = "";
		var messageId = "";

		var finish = super.bean( "Finish" );
		var status = super.bean( "Status" );

		finish.setId( json.id );
		finish.setCode( json.code );

		for ( var thisCategory in json.selectedCategories ) {
			var category = super.bean( "ProductCategory" );

			category.setId( thisCategory.id );
			categories.add( category );
		}

		finish.setCategories( categories );
		finish.setStatus( status.setId( json.status.id ) );

		var nameItem        = super.buildTextBean( json.nameItem, "NAME" );
		var descriptionItem = super.buildTextBean( json.descriptionItem, "DESC" );

		finish.setTexts( [ nameItem, descriptionItem ] );

		if ( !Len( json.id ) ) {
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

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "finish.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "finish.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "finish.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
