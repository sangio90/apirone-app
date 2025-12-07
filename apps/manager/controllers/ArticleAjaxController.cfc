component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var params = super.paramsFromUrl();


		var rows = super.fire( "article.search", params );

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
		param rc.id = "___";
		var result  = super.getResult();

		if ( !super.isUuid( rc.id ) ) {
			return event.setValue( "result", "No UUID" );
		}

		var bean = super.fire( "article.get", [ rc.id ] );

		var obj = super.getMementify().convert( bean );

		result.setData( obj );

		event.setValue( "result", result );
	}

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "article.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId     = "";
		var messageId  = "";

		var result = super.getResult();

		var status  = super.bean( "Status" );
		var article = super.bean( "Article" );
		var type    = super.bean( "ArticleType" );
		var price   = super.bean( "Price" );

		article.setId( json.id );
		article.setCode( json.code );
		article.setExternalId( json.externalId );

		article.setStatus( status.setId( json.status.id ) );
		article.setType( type.setId( json.type.id ) );
		
		var nameItem        = super.buildTextBean( json.nameItem, "NAME" );
		var descriptionItem = super.buildTextBean( json.descriptionItem, "DESC" );
		
		article.setTexts( [ nameItem, descriptionItem ] );

		price.setId( json.price.id );
		price.setAmount( Val( json?.price?.amount ) ? json.price.amount : 0 );
		
		article.setPrice( price );

		if ( !Len( json.id ) ) {
			messageId = "article.created";
			thisId    = super.fire( "article.create", [ article ] );
		} else {
			messageId = "article.updated";
			thisId    = super.fire( "article.update", [ article ] );
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { "id" = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var json      = GetHTTPRequestData().content;
		var messageId = "article.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( json );

		for ( var id in ids ) {
			var outcome = super.fire( "article.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "article.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}

