component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var params = super.paramsFromUrl();

		if ( rc.keyExists( "typeId" ) ) {
			params[ "typeId" ] = rc.typeId
		}

		var rows = super.fire( "ProductCategory.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var content   = GetHTTPRequestData().content;
		var messageId = "productCategory.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( content );

		for ( var id in ids ) {
			var outcome = super.fire( "productCategory.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "productCategory.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}


	function save( event, rc, prc ){
		var result = super.getResult();

		// var text     = super.bean( "Text" );
		// var lang     = super.bean( "Lang" );
		// var status   = super.bean( "Status" );
		var status   = super.bean( "Status" );
		var mode     = super.bean( "ProductCategoryMode" );
		var type     = super.bean( "ProductCategoryType" );
		var category = super.bean( "ProductCategory" );

		var thisId    = "";
		var messageId = "";

		var json = DeserializeJSON( GetHTTPRequestData().content );

		category.setId( json.id );
		category.setCode( json.code );

		category.setType( type.setId( json.type.id ) );
		category.setMode( mode.setId( json.mode.id ) );
		category.setStatus( status.setId( json.status.id ) );

		// text.setLang( lang.setId( json.nameItem.lang.id ) );

		var text = super.buildTextBean( json.nameItem, "NAME" );

		// text.setId( json.nameItem.id );
		// text.setName( json.nameItem.name );

		category.setTexts( [ text ] );

		if ( !Len( json.id ) ) {
			messageId = "productCategory.created";
			thisId    = super.fire( "productCategory.create", [ category ] )
		} else {
			messageId = "productCategory.updated";
			thisId    = super.fire( "productCategory.update", [ category ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "productCategory.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

}
