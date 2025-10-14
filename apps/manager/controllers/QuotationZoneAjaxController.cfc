component extends="com.apirone.core.controller.AbsController" {

	property name="dao" inject="QuotationZoneDAO";
	property name="quotationItemDao" inject="QuotationItemDAO";

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

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId    = "";
		var messageId = "";
		var texts     = [];
		var errors    = [];

		var result = super.getResult();

		var quotationZone = super.bean( "QuotationZone" );

		var params = {
			quotationId = json.quotation.id,
			name        = json.name,
			originId    = Len( json.parentZone?.id ) ? json.parentZone.id : null
		}

		// TODO: move to service
		var existingCombination = dao.find( argumentCollection = params );

		if ( !Len( existingCombination ) ) {
			quotationZone.setQuotation( super.service( "Quotation" ).get( json.quotation.id ) );
			quotationZone.setName( json.name );

			if ( Len( json.parentZone?.id ) ) {
				quotationZone.setOrigin( super.service( "QuotationZone" ).get( json.parentZone.id ) );
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
			result.setData( {
				"error" = "Combinazione Zona già esistente in questo preventivo."
			} );
			result.setStatus( "ERRORE" );
			event.setValue( "result", result );
			return;
		}

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var json       = DeserializeJSON( GetHTTPRequestData().content );
		
		var validation = super.getValidationResult();
		var result     = super.getResult();
		
		var payload    = {};
		var zone       = json.zone;

		if ( !IsNull( zone ) ) {

			/*
			var zoneInUse = super.fire( "quotationItem.search", [ quotationZoneId = zone.id ] );

			if( Len( zoneInUse.getData() ) ) {
				var error = getValidationError( message = getMessage( "zone.notDeletedWithQuotationItem" ), field="parentId" );
				validation.addError( error );
			}

			var zoneWithSubzone = super.fire( "quotationZone.search", [ originId = zone.id ] );

			if ( Len( zoneWithSubzone.getData() ) ) {
				var error = getValidationError( message = getMessage( "zone.notDeletedWithSubZone" ), field="parentId" );
				validation.addError( error );
			}
				
			if ( validation.hasErrors() ) {
				event.setValue( "result", validation );
				return;
			}
			*/

		}

		var outcome = super.fire( "quotationZone.delete", [ zone.id ] );

		if ( outcome.hasError() ) {
			var error = getValidationError( message = getMessage( "zone.notDeleted" ), field="general" );
			validation.addError( error );
			event.setValue( "result", validation );
			return;
		}

		result.setData( { "message" = getMessage( "zone.deleted" )  } );

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
