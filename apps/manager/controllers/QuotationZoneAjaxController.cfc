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

		dump()

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

		var existingCombination = super.service( "QuotationZone" ).search( argumentCollection = params );

		if( Len( existingCombination.getData() ) ) {
			
			var error = super.getValidationError( message = getMessage( "zone.existInQuotation" ), field="name" );
			validation.addError( error );

			event.setValue( "result", validation );
			return;

		}

		quotationZone.setQuotation( super.service( "Quotation" ).get( json.quotation.id ) );
		quotationZone.setName( json.name );
		quotationZone.setQuantity( json.quantity );

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
		
		var message = getMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function duplicate( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );
		
		var result = super.getResult();
		var validation = super.getValidationResult();
		
		var quotationZone = super.bean( "QuotationZone" );

		var zoneToDuplicate = super.fire( "QuotationZone.get", [ json.parentZone.id ] );

		var zoneObject = {
			quotationId = json.quotation.id,
			name = json.name,
			quantity = json.quantity,
			originId = !isNull( zoneToDuplicate.getOrigin() ) ?	zoneToDuplicate.getOrigin().getId() : null,
		}

		var existingCombination = super.service( "QuotationZone" ).search( argumentCollection = zoneObject );

		if( Len( existingCombination.getData() ) ) {
			
			var error = super.getValidationError( message = getMessage( "zone.existInQuotation" ), field="name" );
			validation.addError( error );

			event.setValue( "result", validation );
			return;

		}

		quotationZone.setQuotation( super.service( "Quotation" ).get( json.quotation.id ) );
		quotationZone.setName( json.name );
		quotationZone.setQuantity( json.quantity );

		if ( !isNull( zoneObject.originId ) ) {
			quotationZone.setOrigin( zoneToDuplicate.getOrigin() );
		}

		transaction {
			if ( !Len( json.id ) ) {
				messageId = "quotationZone.created";
				thisId    = super.fire( "quotationZone.create", [ quotationZone ] )
			} else {
				messageId = "quotationZone.updated";
				thisId    = super.fire( "quotationZone.update", [ quotationZone ] )
			}

			var duplicatedZone = super.service( "QuotationZone" ).duplicateZoneItems( duplicatedZoneId: zoneToDuplicate.getId(), newZoneId: thisId  );
			if (json.duplicaConSottozone) {
				var sottozone = super.service( "QuotationZone" ).list( originId = zoneToDuplicate.getId() )
				for (sottozona in sottozone) {
					var newSottozona = super.bean( "QuotationZone" );
					newSottozona.setQuotation( super.service( "Quotation" ).get( json.quotation.id ) );
					newSottozona.setName( sottozona.getName() );
					newSottozona.setQuantity( sottozona.getQuantity() );
					newSottozona.setOrigin( duplicatedZone );
					var newSottozonaId = super.fire( "quotationZone.create", [ newSottozona ] )
					super.service( "QuotationZone" ).duplicateZoneItems( duplicatedZoneId: sottozona.getId(), newZoneId: newSottozonaId  );
				}
			}
		}
		
		var message = getMessage( messageId );

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
