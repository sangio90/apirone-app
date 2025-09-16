component extends="com.apirone.core.controller.AbsController" {
	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var rows = super.fire( "QuotationItem.search", params );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( rows.getData() );

		event.setValue( "result", result );
	}

	function editSignage( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var params = super.paramsFromUrl();
		// var mm     = super.getMementify();

		params[ "quotationItemId" ] = rc.id;
		
		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );
		var parsedQuotationItemData = {};

		var signageConfig = super.fire('SignageConfig.get', { signageConfigId = quotationItem.getSignageConfigItem().getSignageConfigId() });

		parsedQuotationItemData['id'] = quotationItem.getId();
		parsedQuotationItemData['price'] = quotationItem.getPrice();
		parsedQuotationItemData['quantity'] = quotationItem.getQuantity();
		parsedQuotationItemData['category']['id'] = signageConfig.getCatalogBundle().getCategory().getId();
		parsedQuotationItemData['finish']['id'] = quotationItem.getProduct().getFinish().getId();
		parsedQuotationItemData['line']['id'] = signageConfig.getCatalogBundle().getLine().getId();
		parsedQuotationItemData['model']['id'] = signageConfig.getCatalogBundle().getModel().getId();
		parsedQuotationItemData['font']['id'] = signageConfig.getFont().getId();
		parsedQuotationItemData['fontSize']['id'] = quotationItem.getSignageConfigItem().getId();
		parsedQuotationItemData['zone']['id'] = quotationItem.getQuotationZone().getId();
		parsedQuotationItemData['signageRows'] = [];
		quotationItem.getSignageRows().each((row) => {
			arrayAppend(parsedQuotationItemData['signageRows'], row);
		});

		// var obj = mm.convert( parsedQuotationItemData, "list" );
		// data.add( obj );

		result.setData( parsedQuotationItemData );
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
				if ( !Len( json.id ) ) {
					var quotationItemSignageBean = super.bean( "QuotationItemSignage" );
				} else {
					var quotationItemSignageBean = super.fire('QuotationItem.get', { quotationItemId = json.id});
					if (IsNull(quotationItemSignageBean)) {
						var quotationItemSignageBean = super.bean( "QuotationItemSignage" );
					}
				}
				quotationItemSignageBean.setSignageConfigItem(
					super.service( "SignageConfigItem" ).get( json.signageConfigItem.id )
				);
				quotationItemSignageBean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
				quotationItemSignageBean.setQuotationZone(super.service( "QuotationZone" ).get( json.zone.id ));
				quotationItemSignageBean.setPrice( 20.1 );
				quotationItemSignageBean.setQuantity( json.quantity );
				var product = super.fire( 'Product.search', { lineId = json.line.id, modelId = json.model.id, categoryId: json.category.id, finishId: json.finish.id} ).getData();
				if (!Len(product) || Len(product) > 1) {
					var message = "Prodotto non valido.";
					result.setData( { "error" = e.message } );
					result.setStatus( "ERRORE" );
					event.setValue( "result", result );
					return;
				}
				product = product[1];
				quotationItemSignageBean.setProduct(super.fire( 'Product.get', { 'productId' = product.getId() }));
				if ( !Len( json.id ) ) {
					messageId = "quotationItem.created";
					thisId    = super.fire( "quotationItem.create", [ quotationItemSignageBean ] )
				} else {
					messageId = "quotationItem.updated";
					thisId    = super.fire( "quotationItem.update", [ quotationItemSignageBean ] )
				}
				for ( signageRow in json.signageRows._data ) {
					if ( !Len( signageRow.id ) ) {
						var signageRowBean = super.bean( "QuotationItemSignageRow" );
						var messaggiId      = "QuotationItemSignageRow.create";
					} else {
						var signageRowBean = super.fire( "QuotationItemSignageRow.get", { quotationItemSignageRowId = signageRow.id } );
						var messaggiId      = "QuotationItemSignageRow.update";
					}
					signageRowBean.setQuotationItemId( thisId );
					signageRowBean.setTextAlign( signageRow.textAlign );
					signageRowBean.setContent( signageRow.content );
					signageRowBean.setCharCount( signageRow.charCount );
					signageRowBean.setOrderby( signageRow.orderby );

					super.fire( messaggiId, [ signageRowBean ] );
				}

				var message = completeMessage( messageId );
			} catch ( any e ) {
				var message = "Errore nella creazione/aggiornamento della riga di preventivo: #e.message#";
				result.setData( { "error" = e.message } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
			}
		}

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

}
