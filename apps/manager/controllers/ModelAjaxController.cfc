component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mm     = getMementify();

		var params = super.paramsFromUrl();

		var rows = super.fire( "model.search", params );

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

		var result = super.fire( "model.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var categories = [];

		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var result = super.getResult();

		var model           = super.bean( "Model" );
		var type            = super.bean( "ModelType" );
		var status          = super.bean( "Status" );
		var nameText        = super.bean( "Text" );
		var descriptionText = super.bean( "Text" );
		var nameKind        = super.bean( "TextKind" );
		var descriptionKind = super.bean( "TextKind" );
		var lang            = super.bean( "Lang" );

		model.setId( json.id );
		model.setCode( json.code );
		model.setType( type.setId( json.type.id ) );

		if ( Len( json?.selectedCategories ) ) {
			for ( var thisCategory in json.selectedCategories ) {
				var category = super.bean( "ProductCategory" );

				category.setId( thisCategory.id );
				categories.add( category );
			}
		}

		nameText.setLang( lang.setId( json.nameItem.lang.id ) );
		nameText.setStatus( status.setId( "TRA" ) );
		nameText.setId( json.nameItem.id );
		nameText.setName( json.nameItem.name );

		descriptionText.setLang( lang.setId( json.descriptionItem.lang.id ) );
		descriptionText.setStatus( status.setId( "TRA" ) );
		descriptionText.setId( json.descriptionItem.id );
		descriptionText.setName( json.descriptionItem.name );

		model.setTexts( [ nameText, descriptionText ] );

		model.setCategories( categories );
		model.setStatus( status.setId( json.status.id ) );
		model.setFruitsCount( Len( json.fruitsCount ) ? json.fruitsCount : NullValue() );

		if ( !Len( json.id ) ) {
			messageId = "model.created";
			thisId    = super.fire( "model.create", [ model ] )
		} else {
			messageId = "model.updated";
			thisId    = super.fire( "model.update", [ model ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "model.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "model.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "model.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
