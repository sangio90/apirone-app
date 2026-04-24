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
