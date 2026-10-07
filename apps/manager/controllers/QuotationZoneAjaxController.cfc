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
			messageId = "zone.created";
			thisId    = super.fire( "quotationZone.create", [ quotationZone ] )
		} else {
			quotationZone.setId( json.id )
			messageId = "zone.updated";
			thisId    = super.fire( "quotationZone.update", [ quotationZone ] )
		}

		quotationZoneId = rc.id;
		if (isNull(quotationZoneId)) {
			quotationZoneId = thisId;
		}

		// Se la sottozona non ha img, prendo quella del parent
		if (!IsNull(quotationZone.getOrigin()) && IsNull(quotationZone.getImage()) ) {
			var parentQuotationZone = super.service( "QuotationZone" ).get( quotationZone.getOrigin().getId() );
			if ( !IsNull( parentQuotationZone ) && !IsNull( parentQuotationZone.getImage() ) ) {
				var oldImage = parentQuotationZone.getImage();
				oldImage.setId( null );
				var entity = super.bean( "Entity" );
				entity.setKey( "quotationZone.id" );
				entity.setValue( quotationZone.getId() );
				super.service( "File" ).getDao().duplicateQuotationZoneFile(file = oldImage, quotationZoneId = quotationZoneId );
			}
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

	/**
	 * Cancella una zona. Se contiene righe di preventivo la prima chiamata non
	 * cancella nulla e risponde status "confirm" con il numero di righe: il client
	 * chiede conferma all'utente e ripete la chiamata con force = true, che cancella
	 * righe e zona insieme. Le zone con sottozone restano non cancellabili.
	 */
	function delete( event, rc, prc ){
		var json   = DeserializeJSON( GetHTTPRequestData().content );
		var result = super.getResult();
		var zone   = json.zone ?: NullValue();
		var force  = IsBoolean( json.force ?: false ) && ( json.force ?: false );

		if ( IsNull( zone ) || !Len( zone.id ?: "" ) ) {
			result.setData( { "message" = getMessage( "zone.notDeleted" ), "status" = "error" } );
			event.setValue( "result", result );
			return;
		}

		var zoneBean = super.fire( "quotationZone.get", [ zone.id ] );
		if ( !IsNull( zoneBean ) && !IsNull( zoneBean.getQuotation() )
			&& super.rejectIfQuotationLocked( event, zoneBean.getQuotation().getId() ) ) return;

		var zoneWithSubzone = super.fire( "quotationZone.search", [ originId = zone.id ] );

		if ( Len( zoneWithSubzone.getData() ) ) {
			result.setData( { "message" = getMessage( "zone.notDeletedWithSubZone" ), "status" = "error" } );
			event.setValue( "result", result );
			return;
		}

		var zoneItems = super.fire( "quotationItem.list", { quotationZoneId = zone.id } );

		if ( ArrayLen( zoneItems ) && !force ) {
			result.setData( {
				"status"     = "confirm",
				"itemsCount" = ArrayLen( zoneItems ),
				"message"    = "La zona contiene #ArrayLen( zoneItems )# #ArrayLen( zoneItems ) == 1 ? 'riga' : 'righe'# del preventivo: eliminando la zona verranno eliminate anche queste."
			} );
			event.setValue( "result", result );
			return;
		}

		transaction {
			try {
				// stesse operazioni della cancellazione di una singola riga
				// ( QuotationItemAjaxController.delete ): prima tutte le righe, poi
				// il ricalcolo dei prezzi delle righe rimaste che condividono costi
				// fissi ( linea / finitura / modello o prodotto ), una volta per gruppo
				var repricings = {};

				for ( var item in zoneItems ) {
					var outcome = super.fire( "quotationItem.delete", [ item.getId() ] );
					if ( outcome.getStatus() == "ERROR" ) {
						throw( message = outcome.getMessage(), detail = outcome.getError().message ?: "" );
					}

					var quotationId = item.getQuotation().getId();

					if ( IsInstanceOf( item, "com.apirone.core.model.bean.QuotationItemPlate" ) || IsInstanceOf( item, "com.apirone.core.model.bean.QuotationItemSignage" ) ) {
						var modelId = !IsNull( item.getProduct().getModel() ) ? item.getProduct().getModel().getId() : "";
						var key = "lfm|" & item.getProduct().getLine().getId() & "|" & item.getProduct().getFinish().getId() & "|" & modelId;
						repricings[ key ] = {
							"action" = "quotationItem.aggiornaPrezzoAltriArticoliByQuotationIdLineIdFinishId",
							"args"   = {
								"quotationId"     = quotationId,
								"quotationItemId" = item.getId(),
								"lineId"          = item.getProduct().getLine().getId(),
								"finishId"        = item.getProduct().getFinish().getId(),
								"modelId"         = modelId
							}
						};
					} else if ( IsNull( item.getArticle() ) ) {
						repricings[ "p|" & item.getProduct().getId() ] = {
							"action" = "quotationItem.aggiornaPrezzoAltriArticoliByQuotationIdAndProductId",
							"args"   = {
								"quotationId"     = quotationId,
								"quotationItemId" = item.getId(),
								"productId"       = item.getProduct().getId()
							}
						};
					}
				}

				var zoneOutcome = super.fire( "quotationZone.delete", [ zone.id ] );
				if ( zoneOutcome.getStatus() == "ERROR" ) {
					throw( message = zoneOutcome.getMessage(), detail = zoneOutcome.getError().message ?: "" );
				}

				for ( var key in repricings ) {
					super.fire( repricings[ key ].action, repricings[ key ].args );
				}
			} catch ( any e ) {
				transaction action="rollback";
				writeLog( type = "error", file = "application", text = "Cancellazione zona #zone.id# non riuscita: #e.message# #e.detail#" );
				result.setData( { "message" = getMessage( "zone.notDeleted" ), "status" = "error" } );
				event.setValue( "result", result );
				return;
			}
		}

		var message = getMessage( "zone.deleted" );
		if ( ArrayLen( zoneItems ) ) {
			message &= " insieme a #ArrayLen( zoneItems )# #ArrayLen( zoneItems ) == 1 ? 'riga' : 'righe'#";
		}

		result.setData( { "message" = message, "status" = "success" } );
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
