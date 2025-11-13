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

	function editAccessory( event, rc, prc ){
		var data   = {}
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mm     = super.getMementify();

		params[ "quotationItemId" ] = rc.id;

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var parsedQuotationItemData = mm.convert( quotationItem, "edit" );

		data.append( {
			"quotationItem" = parsedQuotationItemData
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
			fileName   = "preview_" & json.mode & "_id_" & json.quotationItem.id & ".png";
			filePath   = tmpDir & "/" & fileName;
			binaryData = ToBinary( json.imageBase64 );

			FileWrite( filePath, binaryData );

			var id = json.quotationItem.id;
			var type = json.type
			try {
				if ( !Len( id ) ) {
					if (json.mode == 'segnaletiche') {
						var bean = super.bean( "QuotationItemSignage" );
					} else {
						var bean = super.bean( "QuotationItem" );
					}
				} else {
					var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
					if ( IsNull( bean ) ) {
						var bean = super.bean( "QuotationItemSignage" );
					}
				}

				if ( json.mode == 'segnaletiche' ) {
					bean.setSignageConfigItem(
						super.service( "SignageConfigItem" ).get( json.quotationItem.signageConfigItem.id )
					);
				}

				bean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
				bean.setQuotationZone(
					super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id )
				);
				bean.setPrice( 20.1 );
				bean.setQuantity( json.quotationItem.quantity );

				if (json.mode == 'segnaletiche') {
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
				} else {
					var product = super
					.fire(
						"Product.search",
						{
							lineId     = json.quotationItem.product.catalogBundle.line.id,
							modelId    = json.quotationItem.product.catalogBundle.model.id,
							categoryId = json.quotationItem.product.catalogBundle.category.id,
							finishId   = json.quotationItem.product.finish.id
						}
					)
					.getData();
				}
				
				if ( !Len( product ) || Len( product ) > 1 ) {
					var message = "Combinazione Linea/Modello/Categoria/Finitura non disponibile.";
					result.setData( { "error" = message } );
					result.setStatus( "ERRORE" );
					event.setValue( "result", result );
					return;
				}
				product = product[ 1 ];
				bean.setProduct(
					super.fire( "Product.get", { "productId" = product.getId() } )
				);
				if ( !Len( id ) ) {
					messageId = "quotationItem.created";
					thisId    = super.fire( "quotationItem.create", [ bean ] )
				} else {
					messageId = "quotationItem.updated";
					thisId    = super.fire( "quotationItem.update", [ bean ] )
				}

				if ( json.mode == 'segnaletiche' ) {
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
						quotationItemProductItemBean.setQuotationItemId( thisId );
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
		var result     = super.getResult();
		var validation = getValidationResult();

		var id = GetHTTPRequestData().content;

		var outcome = super.fire( "quotationItem.delete", [ id ] );

		if ( outcome.getStatus() == "ERROR" ) {
			var error = super.getValidationError(
				message = getMessage( "quotationItem.notDeleted" ),
				field   = "general"
			);
			validation.addError( error );

			event.setValue( "result", validation );
			return;
		}

		result.setData( { "message" = getMessage( "quotationItem.deleted" ) } );

		event.setValue( "result", result );
	}

	function productItems( event, rc, prc ){
		var result = super.getResult();
		var memny  = super.getMementify();

		var quotationItemId = rc.id;

		var productItems = super.fire( "QuotationItemProductItem.list", { quotationItemId = quotationItemId } );

		var productItems = memny.convertList( productItems );

		result.setCount( Len( productItems ) );
		result.setData( productItems );

		event.setValue( "result", result );
	}

}
