component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mm     = super.getMementify();

		params[ "quotationId" ] = rc.quotationId;

		var rows = super.fire( "QuotationZone.search", params );
		var dataRows = orderByOrigin( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		//result.setData( mm.convertList( dataRows, "list" ) );
		result.setData( dataRows );

		event.setValue( "result", result );
	}

	function listPositions( event, rc, prc ){

		param rc.zoneId="";
		
		var memy   = super.getMementify();
		var result = super.getResult();
		var data   = [];

		if( !Len( rc.zoneId ) ){
			var result = super.getResult();
			result.setData( [] );
			event.setValue( "result", result );
			return;
		}

		var params = super.paramsFromUrl();

		params[ "zoneId" ] = rc.zoneId;

		var rows = super.fire( "QuotationZonePosition.list", params );

		var data = memy.convertList( rows, "list" ) 

		result.setData( data );

		result.setTotal( rows.len() );
		result.setCount( rows.len() );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );
		
		var result = super.getResult();
		var validation = super.getValidationResult();
		
		var quotationZone = super.bean( "QuotationZone" );

		var params = {
			quotationId = json.quotation.id,
			name        = json.name,
			originId    = Len( json.parentZone?.id ) ? json.parentZone.id : null
		}

		var existingCombinations = super.service( "QuotationZone" ).search( argumentCollection = params );

		if( Len( existingCombinations.getData() ) ) {
			var existingCombination = existingCombinations.getData()[1]
			if (isNull(json.id) || json.id == "" || existingCombination.getId() != json.id) {
				result.setData( { "message" = getMessage( "zone.existInQuotation" ), "status" = "error" } );
				event.setValue( "result", result );
				return;
			}
		}

		quotationZone.setQuotation( super.service( "Quotation" ).get( json.quotation.id ) );
		quotationZone.setName( json.name );
		quotationZone.setQuantity( json.quantity );

		if ( Len( json.parentZone?.id ) ) {
			if (!isNull(json.id)) {
				var children = super.service( "QuotationZone" ).list( "originId" = rc.id );
				if (Len(children) > 0) {
					result.setData( { "message" = "Non è possibile assegnare una zona padre ad una zona con sottozone.", "status" = "error" } );
					event.setValue( "result", result );
					return;
				}
			}

			quotationZone.setOrigin( super.service( "QuotationZone" ).get( json.parentZone.id ) );
		} else {
			quotationZone.setOrigin( null );
		}

		if ( isNull( json.id ) ) {
			messageId = "quotationZone.created";
			thisId    = super.fire( "quotationZone.create", [ quotationZone ] )
		} else {
			quotationZone.setId( json.id )
			messageId = "quotationZone.updated";
			thisId    = super.fire( "quotationZone.update", [ quotationZone ] )
		}
		
		var message = getMessage( messageId );

		result.setData( { "message" = message, "status" = "success" }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function duplicate( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );
		
		var result = super.getResult();
		var validation = super.getValidationResult();
		
		var duplicateResult = super.fire( "QuotationZone.duplicate" , [ 'zoneId' = json.id, 'quotationId' = json.quotation.id, 'duplicaConSottozone' = json.duplicaConSottozone, 'name' = json.name ]);
		
		var message = getMessage( duplicateResult.messageId );

		result.setData( { "message" = message }, { "payload" = { id = duplicateResult.zoneId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var json       = DeserializeJSON( GetHTTPRequestData().content );
		
		var validation = super.getValidationResult();
		var result     = super.getResult();
		
		var payload    = {};
		var zone       = json.zone;

		if ( !IsNull( zone ) ) {

			var zoneInUse = super.fire( "quotationItem.search", [ quotationZoneId = zone.id ] );

			if( Len( zoneInUse.getData() ) ) {
				result.setData( { "message" = getMessage( "zone.notDeletedWithQuotationItem" ), "status" = 'error' } );
				event.setValue( "result", result );
				return;
			}

			var zoneWithSubzone = super.fire( "quotationZone.search", [ originId = zone.id ] );

			if ( Len( zoneWithSubzone.getData() ) ) {
				result.setData( { "message" = getMessage( "zone.notDeletedWithSubZone" ), "status" = 'error' } );
				event.setValue( "result", result );
				return;
			}
				
			if ( validation.hasErrors() ) {
				result.setData( { "message" = "Errore generico durante la cancellazione della Zona.", "status" = 'error' } );
				event.setValue( "result", result );
				return;
			}

		}

		var outcome = super.fire( "quotationZone.delete", [ zone.id ] );

		result.setData( { "message" = getMessage( "zone.deleted" ), "status" = "success"  } );

		event.setValue( "result", result );
	}

	function orderByOrigin( zones ){
		var parsedZones        = [];
		var zonesWithoutOrigin = ArrayFilter( zones, function( zone ){
			return IsNull( zone.getOrigin() );
		} );
		var zonesWithOrigin = ArrayFilter( zones, function( zone ){
			return !IsNull( zone.getOrigin() );
		} );
		zonesWithoutOrigin.each( function( zone ){
			parsedZones.add( zone );
			zonesWithOrigin.each( function( childZone ){
				if ( childZone.getOrigin().getId() == zone.getId() ) {
					parsedZones.add( childZone );
				}
			} );
		} );

		return parsedZones;
	}

}
