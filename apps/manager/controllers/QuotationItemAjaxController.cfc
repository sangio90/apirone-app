component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data                = [];
		var result              = super.getResult();
		var params              = super.paramsFromUrl();
		params[ "quotationId" ] = rc.quotationId;
		if ( Len( rc.zoneId ) ) {
			params[ "quotationZoneId" ] = rc.zoneId;
		}
		var rows = super.fire( "QuotationItem.search", params );
		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( rows.getData() );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var result = super.getResult();

		transaction {
			try {
				var quotationItemSignageBean = super.bean( "QuotationItemSignage" );
				quotationItemSignageBean.setSignageConfigItem(
					super.service( "SignageConfigItem" ).get( json.signageConfigItem.id )
				);
				quotationItemSignageBean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
				quotationItemSignageBean.setPrice( 20.1 );
				quotationItemSignageBean.setQuantity( json.quantita );
				if ( !Len( json.id ) ) {
					messageId = "quotationItem.created";
					thisId    = super.fire( "quotationItem.create", [ quotationItemSignageBean ] )
				} else {
					messageId = "quotationItem.updated";
					thisId    = super.fire( "quotationItem.update", [ quotationItemSignageBean ] )
				}

				for ( signageLine in json.signageLines._data ) {
					if ( !Len( signageLine.id ) ) {
						var signageLineBean = super.bean( "QuotationItemSignageRow" );
						var messaggiId      = "QuotationItemSignageRow.create";
					} else {
						var signageLineBean = super.bean( "QuotationItemSignageRow" ).get( singnageLine.id );
						var messaggiId      = "QuotationItemSignageRow.update";
					}
					signageLineBean.setQuotationItem( quotationItemSignageBean.setId( thisId ) );
					signageLineBean.setTextAlign( signageLine.textAlign );
					signageLineBean.setContent( signageLine.content );
					signageLineBean.setCharCount( signageLine.charCount );
					signageLineBean.setOrderby( signageLine.orderby );

					super.fire( messaggiId, [ signageLineBean ] );
				}

				var message = completeMessage( messageId );
			} catch ( any e ) {
				var message = "Errore nella creazione/aggiornamento della riga di preventivo: #e.message#";
				result.setData( { "error" = e.message } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				dump( result );
				return;
			}
		}

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

}
