component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mm     = super.getMementify();
		var rows   = super.fire( "QuotationItem.search", params );

		var rowsData = ( mm.convertList( rows.getData() ) );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( rowsData );

		event.setValue( "result", result );
	}

	function editSignage( event, rc, prc ){
		var data   = {}
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mm     = super.getMementify();

		params[ "quotationItemId" ] = rc.id;

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var parsedQuotationItemData = mm.convert( quotationItem, "edit" );

		var signageConfig = super.fire(
			"SignageConfig.get",
			{
				signageConfigId = quotationItem.getSignageConfigItem().getSignageConfigId()
			}
		);
		var parsedSignageConfigData = ( mm.convert( signageConfig ) );

		data.append( {
			"quotationItem" = parsedQuotationItemData,
			"signageConfig" = parsedSignageConfigData
		} );

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
			var tmpDir = getTempDir();
			fileName   = "preview_segnaletica_id_" & json.quotationItem.id & ".png";
			filePath   = tmpDir & "/" & fileName;
			binaryData = ToBinary( json.imageBase64 );

			FileWrite( filePath, binaryData );

			var id = json.quotationItem.id;
			try {
				if ( !Len( id ) ) {
					var quotationItemSignageBean = super.bean( "QuotationItemSignage" );
				} else {
					var quotationItemSignageBean = super.fire( "QuotationItem.get", { quotationItemId = id } );
					if ( IsNull( quotationItemSignageBean ) ) {
						var quotationItemSignageBean = super.bean( "QuotationItemSignage" );
					}
				}
				quotationItemSignageBean.setSignageConfigItem(
					super.service( "SignageConfigItem" ).get( json.quotationItem.signageConfigItem.id )
				);
				quotationItemSignageBean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
				quotationItemSignageBean.setQuotationZone(
					super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id )
				);
				quotationItemSignageBean.setPrice( 20.1 );
				quotationItemSignageBean.setQuantity( json.quotationItem.quantity );
				var product = super
					.fire(
						"Product.search",
						{
							lineId     = json.signageConfig.catalogBundle.line.id,
							modelId    = json.signageConfig.catalogBundle.model.id,
							categoryId = json.signageConfig.catalogBundle.category.id,
							finishId   = json.quotationItem.product.finish.id
						}
					)
					.getData();
				if ( !Len( product ) || Len( product ) > 1 ) {
					var message = "Combinazione Linea/Modello/Categoria/Finitura non disponibile.";
					result.setData( { "error" = message } );
					result.setStatus( "ERRORE" );
					event.setValue( "result", result );
					return;
				}
				product = product[ 1 ];
				quotationItemSignageBean.setProduct(
					super.fire( "Product.get", { "productId" = product.getId() } )
				);
				if ( !Len( id ) ) {
					messageId = "quotationItem.created";
					thisId    = super.fire( "quotationItem.create", [ quotationItemSignageBean ] )
				} else {
					messageId = "quotationItem.updated";
					thisId    = super.fire( "quotationItem.update", [ quotationItemSignageBean ] )
				}
				for ( var signageRow in json.quotationItem.signageRows._data ) {
					var signageRowBean = super.fire(
						"QuotationItemSignageRow.get",
						{ quotationItemSignageRowId = signageRow.id }
					);

					if ( !Len( signageRowBean ) ) {
						var signageRowBean = super.bean( "QuotationItemSignageRow" );
						var messaggiId     = "QuotationItemSignageRow.create";
					} else {
						var messaggiId = "QuotationItemSignageRow.update";
					}
					signageRowBean.setQuotationItemId( thisId );
					signageRowBean.setTextAlign( signageRow.textAlign );
					signageRowBean.setContent( signageRow.content );
					signageRowBean.setCharCount( signageRow.charCount );
					signageRowBean.setOrderby( signageRow.index );

					super.fire( messaggiId, [ signageRowBean ] );
				}

				var files = super.fire( "File.search", { quotationItemId = thisId } );
				if ( Len( files.getData() ) ) {
					for ( var file in files.getData() ) {
						super.fire( "File.delete", { fileId = file.getId() } );
					}
				}

				var entity = super.bean( "Entity" );

				var kindId = "quotationItem";
				entity.setKey( "quotationItem.id" );
				entity.setValue( thisId );

				var fileId = super.fire(
					"file.create",
					{
						filePath = filePath,
						typeId   = "default",
						kindId   = "quotationItem",
						entity   = entity
					}
				);

				var quotationItemProductItems = super.fire(
					"quotationItemProductItem.list",
					{ quotationItemId = thisId }
				);
				quotationItemProductItems.each( function( quotationItemProductItem ){
					super.fire(
						"quotationItemProductItem.delete",
						{ "productItemId" = quotationItemProductItem.getId() }
					)
				} );

				var productItemsData = json.quotationItem.product.items._data;
				productItemsData.each( function( productItemRow ){
					var selectedValue = selectedValues = ArrayFilter( productItemRow.values, function( v ){
						return v.selected;
					} )
					if ( Len( selectedValue ) > 0 ) {
						selectedValue   = selectedValue[ 1 ];
						var productItem = super.fire(
							"productItem.get",
							{ "productItemId" = selectedValue.product_item_id }
						);

						var quotationItemProductItemBean = super.bean( "quotationItemProductItem" );
						var quotationItem                = super.fire( "quotationItem.get", { "quotationItemId" = thisId } );
						quotationItemProductItemBean.setQuotationItem( quotationItem );
						quotationItemProductItemBean.setProductItem( productItem );
						quotationItemProductItemBean.setOrigin( productItem.getOrigin() );
						quotationItemProductItemBean.setLevel( productItemRow.level );
						quotationItemProductItemBean.setId( thisId )

						super.fire(
							"quotationItemProductItem.create",
							{ "productItem" = quotationItemProductItemBean }
						)
					}
				} )

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

	function delete( event, rc, prc ){
		var result  = super.getResult();
		var id      = GetHTTPRequestData().content;
		//var payload = "";

		//try {
			// REF: in gnere sui delete le transazioni non servono
			//transaction {
				var files = super.fire( "file.list", { quotationItemId = id } );

				// REF: non occorre lo fa il db
				// REF: nel "for" mancherebbe il "var" file
				//for ( 'var' file in files ) {
				//	var outcome = super.fire( "file.delete", [ file.getId() ] );
				//}
				//var signageRows = super.fire( "quotationItemSignageRow.list", { quotationItemId = id } );

				
				// REF: non occorre lo fa il db
				// REF: nel "for" mancherebbe il "var" per signageRow
				//for ( 'var' signageRow in signageRows ) {
				//	var outcome = super.fire( "quotationItemSignageRow.delete", [ signageRow.getId() ] );
				//}

				var outcome = super.fire( "quotationItem.delete", [ id ] );

				if ( outcome.getStatus() == "ERROR" ) {
					// REF: Le transazioni vengono committate di default
					// e ne viene fatto il rollback automaticamente se c'è un errore.
					//transaction action="rollback";
					// REF: convertiamo l'errore in una risposta di validazione per il frontend
					result.setStatus( "INVALID" );
					result.setMessage( outcome.getMessage() );
				}
			//}
			/*
		} catch ( any e ) {
			try {
				transaction action="rollback";
			} catch ( any _ ) {
			}
			result.setStatus( "ERRORE" );
		}
			*/

		result.setData( { "payload" = payload } );
		event.setValue( "result", result );
	}

	function productItems( event, rc, prc ){
		var result          = super.getResult();
		var quotationItemId = rc.id;
		var mm              = super.getMementify();
		var productItems    = super.fire( "QuotationItemProductItem.list", { quotationItemId = quotationItemId } );

		var productItems = ( mm.convertList( productItems ) );

		result.setCount( Len( productItems ) );
		result.setData( productItems );

		event.setValue( "result", result );
	}

}
