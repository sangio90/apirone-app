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
		var data   = {}
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mm     = super.getMementify();

		params[ "quotationItemId" ] = rc.id;
		
		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var parsedQuotationItemData = mm.convert(quotationItem, 'edit');

		var signageConfig = super.fire('SignageConfig.get', { signageConfigId = quotationItem.getSignageConfigItem().getSignageConfigId() });
		var parsedSignageConfigData = (mm.convert(signageConfig));

		data.append( { "quotationItem": parsedQuotationItemData, "signageConfig": parsedSignageConfigData } );

		result.setData( data );
		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var result = super.getResult();

		transaction {
			var id = json.quotationItem.id;
			try {
				if ( !Len( id ) ) {
					var quotationItemSignageBean = super.bean( "QuotationItemSignage" );
				} else {
					var quotationItemSignageBean = super.fire('QuotationItem.get', { quotationItemId = id});
					if (IsNull(quotationItemSignageBean)) {
						var quotationItemSignageBean = super.bean( "QuotationItemSignage" );
					}
				}
				quotationItemSignageBean.setSignageConfigItem(
					super.service( "SignageConfigItem" ).get( json.quotationItem.signageConfigItem.id )
				);
				quotationItemSignageBean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
				quotationItemSignageBean.setQuotationZone(super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id ));
				quotationItemSignageBean.setPrice( 20.1 );
				quotationItemSignageBean.setQuantity( json.quotationItem.quantity );
				var product = super.fire( 'Product.search', { lineId = json.signageConfig.catalogBundle.line.id, modelId = json.signageConfig.catalogBundle.model.id, categoryId: json.signageConfig.catalogBundle.category.id, finishId: json.quotationItem.product.finish.id} ).getData();
				if (!Len(product) || Len(product) > 1) {
					var message = "Prodotto non valido.";
					result.setData( { "error" = e.message } );
					result.setStatus( "ERRORE" );
					event.setValue( "result", result );
					return;
				}
				product = product[1];
				quotationItemSignageBean.setProduct(super.fire( 'Product.get', { 'productId' = product.getId() }));
				if ( !Len( id ) ) {
					messageId = "quotationItem.created";
					thisId    = super.fire( "quotationItem.create", [ quotationItemSignageBean ] )
				} else {
					messageId = "quotationItem.updated";
					thisId    = super.fire( "quotationItem.update", [ quotationItemSignageBean ] )
				}
				for ( signageRow in json.quotationItem.signageRows._data ) {
					var signageRowBean = super.fire( "QuotationItemSignageRow.get", { quotationItemSignageRowId = signageRow.id } );
					
					if ( !Len(signageRowBean) ) {
						var signageRowBean = super.bean( "QuotationItemSignageRow" );
						var messaggiId      = "QuotationItemSignageRow.create";
					} else {
						var messaggiId      = "QuotationItemSignageRow.update";
					}
					signageRowBean.setQuotationItemId( thisId );
					signageRowBean.setTextAlign( signageRow.textAlign );
					signageRowBean.setContent( signageRow.content );
					signageRowBean.setCharCount( signageRow.charCount );
					signageRowBean.setOrderby( signageRow.index );

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
