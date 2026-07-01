component extends="com.apirone.core.controller.AbsController" {

	private Struct function draftToStruct( required draft ){
		return {
			"id"              = arguments.draft.getId(),
			"quotationId"     = arguments.draft.getQuotationId(),
			"quotationZoneId" = arguments.draft.getQuotationZoneId(),
			"itemType"        = arguments.draft.getItemType(),
			"coordinateX"     = arguments.draft.getCoordinateX(),
			"coordinateY"     = arguments.draft.getCoordinateY(),
			"angle"           = arguments.draft.getAngle()
		};
	}

	function get( event, rc, prc ){
		var result = super.getResult();
		var draft  = super.fire( "QuotationItemDraft.get", [ rc.id ] );
		result.setData( draftToStruct( draft ) );
		event.setValue( "result", result );
	}

	function applyToItem( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );
		var draft  = super.fire( "QuotationItemDraft.get", [ rc.id ] );

		transaction {
			try {
				var positions = super.fire( "QuotationItemPosition.list", { quotationItemId = json.quotationItemId } );
				if ( ArrayLen( positions ) ) {
					var firstPos = positions[ 1 ];
					firstPos.setCoordinateX( draft.getCoordinateX() );
					firstPos.setCoordinateY( draft.getCoordinateY() );
					firstPos.setAngle( draft.getAngle() );
					firstPos.setVisible( true );
					super.fire( "QuotationItemPosition.update", [ firstPos ] );
				}
				super.fire( "QuotationItemDraft.delete", [ rc.id ] );
				result.setData( { "message" = "Posizione applicata." } );
				event.setValue( "result", result );
			} catch ( any e ) {
				transaction action="rollback";
				result.setData( { "error" = "Errore nell'applicazione della posizione: #e.message#" } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
			}
		}
	}

	function list( event, rc, prc ){
		var result = super.getResult();
		var drafts = super.fire( "QuotationItemDraft.listByZone", [ arguments.rc.zoneId ] );
		var data   = drafts.map( function( draft ){
			return draftToStruct( draft );
		} );
		result.setData( data );
		event.setValue( "result", result );
	}

	function create( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		var draft  = super.bean( "QuotationItemDraft" );
		draft.setQuotationId( json.quotationId );
		draft.setQuotationZoneId( json.quotationZoneId );
		draft.setItemType( UCase( json.itemType ) );
		draft.setCoordinateX( 0.5 );
		draft.setCoordinateY( 0.5 );
		draft.setAngle( 0 );

		var newId = super.fire( "QuotationItemDraft.create", [ draft ] );
		draft.setId( newId );

		result.setData( draftToStruct( draft ) );
		event.setValue( "result", result );
	}

	function updatePosition( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		super.fire( "QuotationItemDraft.updatePosition", [
			rc.id,
			Val( json.coordinateX ),
			Val( json.coordinateY ),
			Int( Val( json.angle ) )
		] );

		result.setData( { "message" = "Posizione aggiornata." } );
		event.setValue( "result", result );
	}

	function convert( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		var draft    = super.fire( "QuotationItemDraft.get", [ rc.id ] );
		var itemType = draft.getItemType();

		transaction {
			try {
				var status      = super.bean( "Status" );
				var quotation   = super.fire( "Quotation.get", [ draft.getQuotationId() ] );
				var zone        = super.bean( "QuotationZone" );
				zone.setId( draft.getQuotationZoneId() );
				var price       = super.bean( "QuotationItemPrice" );
				var priceMethod = super.bean( "PriceMethod" );
				price.setMethod( priceMethod.setId( "F" ) );
				price.setAmount( 0 );
				price.setDiscount1( 0 );
				price.setDiscount2( 0 );
				price.setQuantity( Val( json.quantity ) ? Val( json.quantity ) : 1 );

				if ( itemType == "PLA" ) {

					var bean        = super.bean( "QuotationItemPlate" );
					var frame       = super.bean( "Frame" );
					var orientation = super.bean( "Orientation" );
					frame.setId( json.frameId );
					frame.setOrientation( orientation.setId( UCase( json.orientationId ) ) );
					bean.setFrame( frame );
					bean.setBlockOrientations( "" );

				} else {

					var product = super.fire( "Product.search", {
						lineId     = json.lineId,
						modelId    = json.modelId,
						categoryId = json.categoryId,
						finishId   = json.finishId
					} ).getData();

					if ( !ArrayLen( product ) ) {
						result.setData( { "error" = "Combinazione Linea/Modello/Categoria/Finitura non disponibile." } );
						result.setStatus( "ERRORE" );
						event.setValue( "result", result );
						transaction action="rollback";
						return;
					}

					var bean = super.bean( "QuotationItem" );
					bean.setProduct( super.fire( "Product.get", { "productId" = product[ 1 ].getId() } ) );

				}

				bean.setQuotation( quotation );
				bean.setQuotationZone( zone );
				bean.setQuantity( Val( json.quantity ) ? Val( json.quantity ) : 1 );
				bean.setStatus( status.setId( "ACT" ) );
				bean.setSpecial( false );
				bean.setCustomImage( false );
				bean.setNote( "" );
				bean.setPrice( price );

				var newItemId = super.fire( "QuotationItem.create", [ bean ] );

				// aggiorna la prima posizione con le coordinate del draft
				var positions = super.fire( "QuotationItemPosition.list", { quotationItemId = newItemId } );
				if ( ArrayLen( positions ) ) {
					var firstPos = positions[ 1 ];
					firstPos.setCoordinateX( draft.getCoordinateX() );
					firstPos.setCoordinateY( draft.getCoordinateY() );
					firstPos.setAngle( draft.getAngle() );
					firstPos.setVisible( true );
					super.fire( "QuotationItemPosition.update", [ firstPos ] );
				}

				super.fire( "QuotationItemDraft.delete", [ rc.id ] );

				result.setData( { "quotationItemId" = newItemId } );
				event.setValue( "result", result );

			} catch ( any e ) {
				transaction action="rollback";
				result.setData( { "error" = "Errore durante la conversione del segnaposto: #e.message#" } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
			}
		}
	}

	function delete( event, rc, prc ){
		var result = super.getResult();

		transaction {
			try {
				super.fire( "QuotationItemDraft.delete", [ rc.id ] );
				result.setData( { "message" = "Segnaposto eliminato." } );
				event.setValue( "result", result );
			} catch ( any e ) {
				transaction action="rollback";
				result.setData( { "error" = "Errore durante l'eliminazione del segnaposto." } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
			}
		}
	}

}
