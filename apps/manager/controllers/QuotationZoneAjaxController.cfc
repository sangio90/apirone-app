component extends="com.apirone.core.controller.AbsController" {
	property name="dao" inject="QuotationZoneDAO";
	property name="quotationItemDao" inject="QuotationItemDAO";

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var params = super.paramsFromUrl();

		params[ "quotationId" ] = rc.quotationId;

		var rows = super.fire( "QuotationZone.search", params );
		dataRows = orderZonesByOrigin(rows.getData());
		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( dataRows );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId    = "";
		var messageId = "";
		var texts     = [];
		var errors  = [];

		var result = super.getResult();

		var quotationZone = super.bean( "QuotationZone" );
		var existingCombination = dao.find( argumentCollection = {
				quotationId = json.quotation.id,
				name        = json.name,
				originId    = Len(json.parentZone) ? json.parentZone.id : null
		} );

		if (!Len(existingCombination)) {
			quotationZone.setQuotation( super.service( "Quotation" ).get( json.quotation.id ) );
			quotationZone.setName(json.name);
			if (Len(json.parentZone)) {
				quotationZone.setOrigin(super.service( "QuotationZone" ).get( json.parentZone.id ));
			}

			if ( !Len( json.id ) ) {
				messageId = "quotationZone.created";
				thisId    = super.fire( "quotationZone.create", [ quotationZone ] )
			} else {
				messageId = "quotationZone.updated";
				thisId    = super.fire( "quotationZone.update", [ quotationZone ] )
			}
			var message = completeMessage( messageId );
		} else {
				result.setData( { "error" = "Combinazione Zona già esistente in questo preventivo." } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
		}

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );
		
		var messageId = "quotation.deletedAllRecords";
		var errors  = [];
		var payload = "";
		var valid = true;
		
		var result    = super.getResult();

		var zone = json.zone;
		var outcome = null;
		if (!isNull(zone)) {
			var zonaInUso = super.fire( "quotationItem.search", [ quotationZoneId = zone.id ] );
			if (Len(zonaInUso.getData())) {
					result.setData( { "error" = "Impossibile eliminare questa zona perché associata ad una riga del preventivo." } );
					result.setStatus( "ERRORE" );
					event.setValue( "result", result );
					return;
			}

			if (structKeyExists(zone, 'origin')) {
				outcome = super.fire( "quotationZone.delete", [ zone.id ] );
			} else {
				var zonaConSottozone = super.fire( "quotationZone.search", [ originId = zone.id ] );
				if (Len(zonaConSottozone.getData())) {
					result.setData( { "error" = "Impossibile eliminare questa zona perché contiene delle sottozone." } );
					result.setStatus( "ERRORE" );
					event.setValue( "result", result );
					return;
				}
				outcome = super.fire( "quotationZone.delete", [ zone.id ] );
			}
		}

		if ( outcome.getStatus() == "ERROR" || isNull(outcome) ) {
			errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
		}

		if ( errors.len() ) {
			messageId = "quotation.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

	function orderZonesByOrigin(zones) {
		var parsedZones = [];
		var zonesWithoutOrigin = arrayFilter(zones, function(zone){
			return isNull(zone.getOrigin());
		});
		var zonesWithOrigin = arrayFilter(zones, function(zone){
			return !isNull(zone.getOrigin());
		});
		zonesWithoutOrigin.each(function (zone) {
			parsedZones.add(zone);
			zonesWithOrigin.each(function (childZone) {
				if (childZone.getOrigin().getId() == zone.getId()) {
					parsedZones.add(childZone);
				}
			});
		});
		
		return parsedZones;
	}

}
