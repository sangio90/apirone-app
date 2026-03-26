component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var params = super.paramsFromUrl();

		var rows = super.fire( "LineCost.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row );
			data.append( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){	
		var body = event.getHTTPContent();
		var json = deserializeJSON( body );

		var thisId     = "";
		var messageId  = "";

		var result    = super.getResult();
		
		var lineCost = super.bean( "LineCost" );
		lineCost.setCost( json.cost );
		var category = super.fire( 'ProductCategory.get', [ json.categoryId ] );
		var line = super.fire( 'Line.get', [ json.lineId ] );
		var finish = super.fire( 'Finish.get', [ json.finishId ] );
		lineCost.setCategory( category );
		lineCost.setLine( line );
		lineCost.setFinish( finish );

		try {
			if ( !Len( json.id ) ) {
				messageId = "LineCost.created";
				thisId    = super.fire( "LineCost.create", [ lineCost ] )
			} else {
				lineCost.setId( json.id );
				messageId= "LineCost.updated";
				thisId    = super.fire( "LineCost.update", [ lineCost ] )
			}
			var message = completeMessage( messageId );
		} catch (e) {
			result.setStatus( "ERROR" )
			message = "Errore nella procedura."
		}

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var messageId = "lineCost.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var id = rc.id

		var outcome = super.fire( "LineCost.delete", [ id ] );

		if ( outcome.getStatus() == "ERROR" ) {
			errors.add( {
				"message" = "Non sono riuscito a cancellare l'Id #id#"
			} )
		}

		if ( errors.len() ) {
			messageId = "LineCost.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}

