component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		param rc.by = "";

		var data   = [];
		var params = super.paramsFromUrl();
		var result = super.getResult();

		var items = super.fire( "component.search", params );

		for ( var item in items.getData() ) {
			var row = convertComponent( item );
			data.add( row );
		}

		result.setTotal( items.getTotal() );
		result.setCount( items.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}	

	function listByType( event, rc, prc ){
		param rc.by = "";

		var data   = [];
		var result = super.getResult();

		var params = getParams( typeId = rc.by, rc = rc );

		var items = super.fire( "component.list", params );

		for ( var item in items ) {
			var row = convertComponent( item );
			data.add( row );
		}

		result.setTotal( items.len() );
		result.setCount( items.len() );
		result.setData( data );

		event.setValue( "result", result );
	}	


	function reassign( event, rc, prc ){
		var result = super.getResult();
		var args   = {};

		args[ rc.category ]     = UCase( Trim( rc.oldParam ) );
		args[ "paramCategory" ] = rc.category;
		args[ "newParam" ]      = UCase( Trim( rc.newParam ) );
		args[ "oldParam" ]      = UCase( Trim( rc.oldParam ) );

		transaction {
			try {
				var rowsCount = super.fire( "component.massiveReassign", args );
				var message   = "";
				if ( rowsCount == 0 ) {
					var message = "Non è stato modificato nessun componente.";
				}
				if ( rowsCount == 1 ) {
					var message = "è stato modificato 1 componente.";
				}
				if ( rowsCount > 1 ) {
					var message = "Sono stati modificati " & rowsCount & " componenti.";
				}
				result.setData( { "message" = message } );
				event.setValue( "result", result );
				return;
			} catch ( any e ) {
				transaction action="rollback";
				var message       = "Errore nella riassegnazione massive dei componenti.";
				result.setData( { "error" = message } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
			}
		}
	}

	function massiveDelete( event, rc, prc ){
		var result = super.getResult();
		var args   = {};

		args[ rc.category ]     = UCase( Trim( rc.oldParam ) );
		args[ "paramCategory" ] = rc.category;
		args[ "oldParam" ]      = UCase( Trim( rc.oldParam ) );

		transaction {
			try {
				var rowsCount = super.fire( "component.massiveDelete", args );
				var message   = "";
				if ( rowsCount == 0 ) {
					var message = "Non è stato cancellato nessun componente.";
				}
				if ( rowsCount == 1 ) {
					var message = "è stato cancellato 1 componente.";
				}
				if ( rowsCount > 1 ) {
					var message = "Sono stati cancellati " & rowsCount & " componenti.";
				}
				result.setData( { "message" = message } );
				event.setValue( "result", result );
				return;
			} catch ( any e ) {
				transaction action="rollback";
				var message       = "Errore nella cancellazione massive dei componenti.";
				result.setData( { "error" = message } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
			}
		}
	}

	function save( event, rc, prc ){
		var result = super.getResult();

		var components = DeserializeJSON( GetHTTPRequestData().content );

		switch ( rc.by ) {
			case "product":
				var component = super.bean( "ComponentProduct" );
				var product   = super.bean( "Product" );

				component.setProduct( product.setId( rc.productId ) );

				break;
			case "item":
				var component = super.bean( "ComponentProductItem" );
				var item      = super.bean( "ProductItem" );

				component.setProductItem( item.setId( rc.itemId ) );

				break;
			case "catalogBundle":
				var component = super.bean( "ComponentCatalogBundle" );

				var model = super.bean( "model" );
				var line  = super.bean( "line" );

				component.setLine( line.setId( rc.lineId ) );
				component.setModel( model.setId( rc.modelId ) );

				break;
			case "attributeValue":
				var component = super.bean( "ComponentAttributeValue" );
				var value     = super.bean( "AttributeValue" );

				component.setAttributeValue( value.setId( rc.attributeValueId ) );

				break;
			case "fruitItem":
				// params = { fruitProductItemId = rc.itemId };
				// break;
			default:
				Throw(
					type    = "apirone.error.component.InvalidSaveType",
					message = "Type save [#rc.typeId#] not valid"
				);
				break;
		}

		var params   = getParams( typeId = rc.by, rc = rc );
		var oldItems = super.fire( "component.list", params );

		var esistingRows = [];

		for ( var thisComponent in components ) {
			if ( thisComponent.id != "" ) {
				ArrayAppend( esistingRows, thisComponent.id );
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
			} else {
				var color      = super.bean( "Color" );
				var variant    = super.bean( "Variant" );
				var rawProduct = super.bean( "RawProduct" );

				color.setId( thisComponent.color.id )
				variant.setId( thisComponent.variant.id )
				rawProduct.setId( thisComponent.rawProduct.id )

				component.setId( thisComponent.id );
				component.setColor( color );
				component.setVariant( variant );
				component.setRawProduct( rawProduct );
				component.setQuantity( thisComponent.quantity );

				if ( Len( component.getId() ) ) {
					super.fire( "component.update", [ component ] );
				} else {
					super.fire( "component.create", [ component ] );
				}
			}
		}

		for ( var oldItem in oldItems ) {
			if ( !esistingRows.find( oldItem.getId() ) ) {
				var beanParam = Duplicate( component );

				beanParam.setId( oldItem.getId() );

				super.fire( "component.deleteByParams", [ beanParam ] );

				super.logEvent(
					event   = "component.deleted",
					message = "Component [#oldItem.getId()#] deleted by params",
					payload = { "component" = beanParam.extractIds(), "from" = rc.by }
				);

				cffile(
					action = "APPEND",
					file   = "#ExpandPath( "/debug.log" )#",
					output = "#Now()# by: #rc.by#; beanParams: #SerializeJSON( beanParam.extractIds() )#"
				);
			}
		}

		var message = completeMessage( "product.componentAdded" );

		result.setData( { "message" = message } );

		event.setValue( "result", result );
	}


	/*
        private methods
    */

	private function convertComponent( required Struct component ){
		// TODO: move to DataMapper

		var product = component.getRawProduct();

		var row = {
			"id"       = component.getId(),
			"typeId"   = component.getTypeId(),
			"kindId"   = component.getKindId(),
			"quantity" = component.getQuantity(),
			"cost"     = {
				"amount" = component.getCost().getAmount()
			},
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
			case "product":
				params = { productId = rc.productId };
				break;
			case "item":
				params = {
					productItemId                  = rc.itemId,
					includeBaseAttributeComponents = true
				};
				break;
			case "catalogBundle":
				params = { lineId = rc.lineId, modelId = rc.modelId };
				break;
			case "fruit":
				params = { fruitId = rc.fruitId };
				getLogger().debug( "ComponentAjaxController.getParams: typeId: 'fruit'. Remove this line" );
				break;
			case "fruitItem":
				params = { fruitProductItemId = rc.itemId };
				getLogger().debug( "ComponentAjaxController.getParams: typeId: 'fruitItem'. Remove this line" );
				break;
			case "attributeValue":
				params = {
					attributeValueId               = rc.attributeValueId,
					includeBaseAttributeComponents = false
				};
				break;
			default:
				Throw( type = "apirone.error.TypeSearchNotValid", message = "Type search [#rc.by#] not valid" );
				break;
		}

		return params;
	}

}
