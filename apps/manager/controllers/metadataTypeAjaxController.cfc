component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var params = super.paramsFromUrl();

		var rows = super.fire( "metadataType.search", params );

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
		param rc.id = "_";
		var result  = super.getResult();

		if ( !IsNumeric( rc.id ) ) {
			return event.setValue( "result", "No Numeric" );
		}

		var bean = super.fire( "metadataType.get", [ rc.id ] );

		var obj = super.getMementify().convert( bean, "list" );

		result.setData( obj );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var result = getResult();

		var messageId = "";
		var thisId    = 0;
		var entities  = [];

		var dataType = super.bean( "DataType" );
		var unit     = super.bean( "MeasurementUnit" );
		var status   = super.bean( "Status" );
		var metaType = super.bean( "MetadataType" );

		for ( var thisEntity in json.selectedEntities ) {
			var entity = super.bean( "Entity" );

			entity.setId( thisEntity.id )
			entities.add( entity );
		}

		metaType.setId( json.id );
		metaType.setCode( json.code );
		metaType.setName( json.name );
		metaType.setStatus( status.setId( json.status.id ) );
		metaType.setMeasurementUnit( unit.setId( json.measurementUnit.id ) );
		metaType.setDataType( dataType.setId( json.dataType.id ) );
		metaType.setEntities( entities );

		if ( !Len( json.id ) ) {
			messageId = "metadataType.created";
			thisId    = super.fire( "metadataType.create", [ metaType ] )
		} else {
			messageId = "metadataType.updated";
			thisId    = super.fire( "metadataType.update", [ metaType ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "metadataType.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "metadataType.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "metadataType.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "metadataType.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
