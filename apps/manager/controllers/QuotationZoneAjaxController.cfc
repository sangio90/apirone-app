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
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var validation = getValidationResult();

		var messageId = "quotation.deletedAllRecords";
		var errors    = [];
		var payload   = "";
		var valid     = true;

		var result = super.getResult();

		var zone    = json.zone;
		var outcome = null;

		/*
			if ( !data.keyExists( "info" ) OR !Len( Trim( data.info ) ) ) {
				var error = getValidationError( message = "[Info] key not found or empty", field = "info" );
				validation.addError( error );
			}

			if ( validation.hasErrors() ) {
				event.setValue( "result", validation );
				return;
			}
		*/

		if ( !IsNull( zone ) ) {

			var zoneInUse = super.fire( "quotationItem.search", [ quotationZoneId = zone.id ] );

			if( Len( zoneInUse.getData() ) ) {
				var error = getValidationError( message = message( "zone.cannotDeleteWithQuotationItem" ), field="parentId" );
				validation.addError( error );
			}

			/*
			if ( StructKeyExists( zone, "origin" ) ) {
				outcome = super.fire( "quotationZone.delete", [ zone.id ] );
			} else {
			*/
				var zoneWithSubzone = super.fire( "quotationZone.search", [ originId = zone.id ] );

				if ( Len( zoneWithSubzone.getData() ) ) {
					var error = getValidationError( message = message( "zone.cannotDeleteWithSubZone" ), field="parentId" );
					validation.addError( error );
				}
				
			//}


			if ( validation.hasErrors() ) {
				event.setValue( "result", validation );
				return;
			}

			outcome = super.fire( "quotationZone.delete", [ zone.id ] );
			
			/*
			if ( Len( zonaInUso.getData() ) ) {
				result.setData( {
					"error" = "Impossibile eliminare questa zona perché associata ad una riga del preventivo."
				} );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
			}
			*/

			/*
			if ( StructKeyExists( zone, "origin" ) ) {
				outcome = super.fire( "quotationZone.delete", [ zone.id ] );
			} else {
				var zonaConSottozone = super.fire( "quotationZone.search", [ originId = zone.id ] );
				if ( Len( zonaConSottozone.getData() ) ) {
					result.setData( {
						"error" = "Impossibile eliminare questa zona perché contiene delle sottozone."
					} );
					result.setStatus( "ERRORE" );
					event.setValue( "result", result );
					return;
				}
				outcome = super.fire( "quotationZone.delete", [ zone.id ] );
			}
			*/
		}

		if ( outcome.getStatus() == "ERROR" || IsNull( outcome ) ) {
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
