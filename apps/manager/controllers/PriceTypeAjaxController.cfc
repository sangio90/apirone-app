component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var result = super.getResult();
		var mm     = super.getMementify();

		var params = super.paramsFromUrl();

		var rows = super.fire( "priceType.search", params );

		var data = mm.convertList( rows.getData(), "list" )

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		param rc.id = "___";
		var result  = super.getResult();

		var bean = super.fire( "priceType.get", [ rc.id ] );

		var obj = super.getMementify().convert( bean, "list" );

		result.setData( obj );

		event.setValue( "result", result );
	}

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "priceType.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId    = "";
		var messageId = "";
		var entities  = [];
		var methods   = [];

		var result    = super.getResult();

		var priceType = super.bean( "PriceType" );
		var status    = super.bean( "Status" );
		var category  = super.bean( "Entity" );

		for ( var thisEntity in json.selectedEntities ) {
			var entity = super.bean( "Entity" );

			entity.setId( thisEntity.id )
			entities.add( entity );
		}

		for ( var thisMethod in json.selectedMethods ) {
			var method = super.bean( "PriceMethod" );

			method.setId( thisMethod.id )
			methods.add( method );
		}

		priceType.setId( json.id );
		priceType.setName( json.name );

		priceType.setStatus( status.setId( json.status.id ) );
		priceType.setEntities( entities );
		priceType.setMethods( methods );

		if ( !Len( json.id ) ) {
			messageId = "priceType.created";
			thisId    = super.fire( "priceType.create", [ priceType ] )
		} else {
			messageId = "priceType.updated";
			thisId    = super.fire( "priceType.update", [ priceType ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "priceType.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "priceType.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "priceType.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}

