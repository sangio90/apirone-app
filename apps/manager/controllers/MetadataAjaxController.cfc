component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		param rc.by = "";

		var data   = [];
		var result = super.getResult();

		var types    = [];
		var metadata = [];

		var params = getParams( typeId = rc.by, rc = rc );

		// var metadataList = super.getMementify().convertList( super.fire( "metadata.list", params ) );
		// var typeObjList  = super.getMementify().convertList( super.fire( "metadataType.list" ) );

		var metadataList = super.fire( "metadata.list", params );
		var typeObjList  = super.fire( "metadataType.list" );

		for ( var typeObj in typeObjList ) {
			// DEVO RESTITUIRE METADATA NON metadataType
			var row  = super.bean( "Metadata" );
			var line = {};

			var found = false;
			for ( var thisMetadata in metadataList ) {
				if ( typeObj.getCode() == thisMetadata.getType().getCode() ) {
					line             = super.getMementify().convert( thisMetadata, "list" );
					line[ "active" ] = true;

					found = true;
				}
			}

			if ( !found ) {
				row.setType( typeObj );

				line             = super.getMementify().convert( row, "list" );
				line[ "active" ] = false;
			}

			metadata.add( line );
		}


		result.setTotal( metadata.len() );
		result.setCount( metadata.len() );
		result.setData( metadata );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result = super.getResult();

		var json = DeserializeJSON( GetHTTPRequestData().content );

		dump( json );

		var metadata = super.bean( "Metadata" );
		var service  = super.service( "Metadata" )

		switch ( rc.by ) {
			case "raw-values":
				for ( var item in json ) {
					var entity = super.bean( "Entity" );
					var type   = super.bean( "MetadataType" );
					entity.setKey( "rawValue.id" );
					entity.setValue( rc.id );

					metadata.setEntity( entity );

					metadata.setId( IsNumeric( json.id ) ? json.id : NullValue() );
					metadata.setValue( json.value );
					metadata.setType( type.setRawMemento( json.type ) );

					metadata.setValue( json.value );

					if ( Len( item.id ) ) {
						service.update( metadata );
					} else {
						service.create( metadata );
					}
				}

				break;
			default:
				Throw( type = "apirone.error.metadata.InvalidSaveType", message = "Type save [#rc.by#] not valid" );
				break;
		}

		var params   = getParams( typeId = rc.by, rc = rc );
		var oldItems = super.fire( "component.list", params );

		var itemExists = [];

		for ( var thisComponent in components ) {
			if ( thisComponent.id != "" ) {
				ArrayAppend( itemExists, thisComponent.id );
			}

			if ( thisComponent.typeId == "base" ) {
				var override = super.bean( "ComponentOverride" );


				override.setId( thisComponent.override.id );
				override.setDeleted( thisComponent.override.deleted );
				override.setQuantity( thisComponent.override.quantity );
				override.setComponentId( thisComponent.id );
				override.setProductItemId( component.getProductItem().getId() );

				if ( Len( thisComponent.override.id ) ) {
					super.fire( "ComponentOverride.update", [ override ] );
				} else {
					super.fire( "ComponentOverride.create", [ override ] );
				}
			}
		}

		var message = completeMessage( "product.componentAdded" );

		result.setData( { "message" = message } );

		event.setValue( "result", result );
	}


	/*
        private methods
    */

	private function getParams( required String typeId, required Struct rc ){
		var params = {}

		switch ( arguments.typeId ) {
			case "raw-values":
				params = { rawValueId = rc.id };
				break;
			default:
				Throw(
					type    = "apirone.error.metadata.TypeSearchNotValid",
					message = "Type search [#rc.by#] not valid"
				);
				break;
		}

		return params;
	}

}
