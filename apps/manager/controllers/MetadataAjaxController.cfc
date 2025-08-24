component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		param rc.by = "";

		var data   = [];
		var result = super.getResult();

		var types    = [];
		var metadata = [];

		var params = getParams( typeId = rc.by, rc = rc );

		var metadataList = super.getMementify().convertList( super.fire( "metadata.list", params ) );
		var typeObjList  = super.getMementify().convertList( super.fire( "metadataType.list" ) );

		for ( var typeObj in typeObjList ) {
			var row = {}

			var found = false;
			for ( var thisMetadata in metadataList ) {
				if ( typeObj.code == thisMetadata.type.code ) {
					row             = thisMetadata;
					row[ "active" ] = true;
				}
			}

			if ( !found ) {
				row             = typeObj;
				row[ "active" ] = false;
			}

			metadata.add( row );
		}

		result.setTotal( metadata.len() );
		result.setCount( metadata.len() );
		result.setData( metadata );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result = super.getResult();

		var components = DeserializeJSON( GetHTTPRequestData().content );

		switch ( rc.by ) {
			case "rawValue":
				// var component = super.bean( "ComponentProduct" );
				var product = super.bean( "Product" );

				component.setProduct( product.setId( rc.productId ) );

				break;
			default:
				Throw(
					type    = "apirone.error.metadata.InvalidSaveType",
					message = "Type save [#rc.typeId#] not valid"
				);
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

	private function convertMetadata( required Struct component ){
		// TODO: move to DataMapper

		var product = component.getRawProduct();

		var row = {
			"id"       = component.getId(),
			"typeId"   = component.getTypeId(),
			"quantity" = component.getQuantity(),
			"override" = {
				"id"       = component?.getOverride()?.getId(),
				"deleted"  = component?.getOverride()?.getDeleted(),
				"quantity" = component?.getOverride()?.getQuantity()
			},
			"totalQuantity" = component.getTotalQuantity(),
			"rawProduct"    = {
				"id"             = product.getId(),
				"name"           = product.getName(),
				"processingType" = {
					"id"   = product.getProcessingType().getId(),
					"name" = product.getProcessingType().getName()
				},
				"measurementUnit" = {
					"id"   = product.getMeasurementUnit().getId(),
					"name" = product.getMeasurementUnit().getName()
				}
			},
			"variant" = {
				"id"   = component.getVariant().getId(),
				"name" = component.getVariant().getName()
			},
			"color" = {
				"id"   = component.getColor().getId(),
				"name" = component.getColor().getName()
			}
		}

		return row;
	}

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
