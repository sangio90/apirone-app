component extends="com.apirone.core.controller.AbsController" {
	function save( event, rc, prc ){
		var result = super.getResult();

		var texts     = [];

		var json = DeserializeJSON( GetHTTPRequestData().content );

		var positions = json.positions;

		transaction {
			try {
				for ( var pos in positions ) {
					var position = super.fire( "QuotationItemPosition.get", [ pos.id ] );
					position.setCoordinateX( pos.coordinateX );
					position.setCoordinateY( pos.coordinateY );
					position.setVisible( pos.visible );
					position.setAngle( int(pos.angle) );
					super.fire( "QuotationItemPosition.update", [ position ] );
				}
					result.setData( { "message" = "Salvataggio massivo posizioni completato." } );
					event.setValue( "result", result );
					return;
			} catch ( any e ) {
				transaction action="rollback";
				var message       = "Errore nel salvataggio massivo delle posizioni.";
				result.setData( { "error" = message } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
			}
		}
	}

	function delete( event, rc, prc ){
		var result     = super.getResult();
		var validation = getValidationResult();


		transaction {
			try {
				var quotationItemPosition = super.fire( "QuotationItemPosition.get", [ rc.key ] );
				var quotationItemService = super.service( "QuotationItem" );
				var quotationItem = quotationItemService.get( quotationItemPosition.getQuotationItemId() );
				quotationItem.setQuantity( quotationItem.getQuantity() - 1 );
				quotationItemService.update( quotationItem );
				var outcome = super.fire( "QuotationItemPosition.delete", { positionId = rc.key } );
				if ( outcome.getStatus() == "ERROR" ) {
					var error = super.getValidationError(
						message = getMessage( "QuotationItemPosition.notDeleted" ),
						field   = "general"
					);
					validation.addError( error );

					event.setValue( "result", validation );
				}
			} catch ( any e ) {
				transaction action="rollback";
				var message       = "Errore nella cancellazione della posizione.";
				result.setData( { "error" = message } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
			}
		}

		result.setData( { "message" = getMessage( "QuotationItemPosition.deleted" ) } );

		event.setValue( "result", result );
	}

	function print( event, rc, prc ){

		var json = DeserializeJSON( rc.data );

		var zoneId = json.zoneId;
		var zone = super.fire( "QuotationZone.get", [ zoneId ] );
		var quotation = zone.getQuotation();
		var quotationItems = super.fire( "QuotationItem.list", [ "quotationZoneId" = zoneId ] );
		var base64Image = json.image ?: "";

		var saveAsName = "print-quotation-plant_#DateTimeFormat(Now(), 'yyyyMMdd-HHnnss')#.pdf";

		var orientation = "portrait";

		if ( len( base64Image ) ) {
			var pureBase64 = reReplace( base64Image, "^data:image/[a-zA-Z]+;base64,", "" );
			var binaryImg  = binaryDecode( pureBase64, "base64" );
			var cfImage    = imageNew( binaryImg );

			if ( cfImage.width > cfImage.height ) {
				orientation = "landscape";
			}
		}

		var params = {
			title   = "Preventivo",
			data    = {
				"zone" = zone,
				"quotation" = quotation,
				"quotationItems" = quotationItems,
				"positions" = json.positions ?: [],
				"image" = base64Image
			},
			pdfArgs = {
				bookmark          = true,
				backgroundVisible = true,
				orientation       = orientation,
				pageType          = "A4",
				overwrite         = true,
				fontEmbed         = true,
				saveAsName        = saveAsName
			}
		}

		var templatePath = "report/template/print-quotation-plant";

		event.renderData( data = view( view = templatePath, args = params ), type = "PDF" );
	}

}
