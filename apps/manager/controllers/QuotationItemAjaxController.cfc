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

		data.append( { "quotationItem" = parsedQuotationItemData } );

		result.setData( data );
		event.setValue( "result", result );
	}

	function saveAccessory( event, rc, prc ){
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var result = super.getResult();


		transaction {
			var tmpDir = getTempDir();
			fileName   = "preview_accessori_id_" & json.quotationItem.id & ".png";
			filePath   = tmpDir & "/" & fileName;
			binaryData = ToBinary( json.imageBase64 );

			FileWrite( filePath, binaryData );

			var id   = json.quotationItem.id;
			var type = json.type
			try {
				if ( !Len( id ) ) {
					var bean = super.bean( "QuotationItem" );
				} else {
					var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
				}

				bean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
				bean.setQuotationZone( super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id ) );
				bean.setPrice( price );
				bean.setQuantity( json.quotationItem.quantity );

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

				if ( !Len( product ) || Len( product ) > 1 ) {
					var message = "Combinazione Linea/Modello/Categoria/Finitura non disponibile.";
					result.setData( { "error" = message } );
					result.setStatus( "ERRORE" );
					event.setValue( "result", result );
					return;
				}
				product = product[ 1 ];
				bean.setProduct( super.fire( "Product.get", { "productId" = product.getId() } ) );
				if ( !Len( id ) ) {
					messageId = "quotationItem.created";
					thisId    = super.fire( "quotationItem.create", [ bean ] )
				} else {
					messageId = "quotationItem.updated";
					thisId    = super.fire( "quotationItem.update", [ bean ] )
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

				var hash = super.fire( "productHash.createHash", { "quotationItemId" = thisId } );
				if ( !IsNull( hash ) ) {
					bean.setHash( hash );
					bean.setId( thisId );
					super.fire( "quotationItem.update", [ bean ] );
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

	function saveSignage( event, rc, prc ){
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var result = super.getResult();

		transaction {
			var tmpDir = getTempDir();
			fileName   = "preview_segnaletiche_id_" & json.quotationItem.id & ".png";
			filePath   = tmpDir & "/" & fileName;
			binaryData = ToBinary( json.imageBase64 );

			FileWrite( filePath, binaryData );

			var id   = json.quotationItem.id;
			var type = json.type
			try {
				if ( !Len( id ) ) {
					var bean = super.bean( "QuotationItemSignage" );
				} else {
					var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
				}

				bean.setSignageConfigItem(
					super.service( "SignageConfigItem" ).get( json.quotationItem.signageConfigItem.id )
				);
				bean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
				bean.setQuotationZone( super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id ) );
				bean.setPrice( 20.1 );
				bean.setQuantity( json.quotationItem.quantity );

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
				bean.setProduct( super.fire( "Product.get", { "productId" = product.getId() } ) );
				if ( !Len( id ) ) {
					messageId = "quotationItem.created";
					thisId    = super.fire( "quotationItem.create", [ bean ] )
				} else {
					messageId = "quotationItem.updated";
					thisId    = super.fire( "quotationItem.update", [ bean ] )
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

				var hash = super.fire( "productHash.createHash", { "quotationItemId" = thisId } );
				if ( !IsNull( hash ) ) {
					bean.setHash( hash );
					bean.setId( thisId );
					super.fire( "quotationItem.update", [ bean ] );
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

	function savePlate( event, rc, prc ){
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";

		var result = super.getResult();
		var tmpDir = super.getTempDir();
		var method = super.bean( "PriceMethod" );
		var price  = super.bean( "QuotationItemPrice" );

		var lines = [];

		price.setAmount( json.price.total );
		price.setDiscount1( Len( json.price?.discount1 ) ? json.price?.discount1 : 0 );
		price.setDiscount2( Len( json.price?.discount2 ) ? json.price?.discount2 : 0 );
		price.setMethod( method.setId( json.price.method.id ) );

		for( var thisLine in json.price.lines ) {
			var line  = super.bean( "PriceLine" );
			line.setName( thisLine.name );
			line.setAmount( thisLine.amount );
			
			lines.add( line );
		}

		price.setLines( lines );

		var fileName   = "preview_plate_id_" & CreateUUID() & ".png";
		var filePath   = tmpDir & "/" & fileName;
		var binaryData = ToBinary( json.imageBase64 );
		var beanFruits = [];

		FileWrite( filePath, binaryData );

		var id = json.id;

		var bean = super.bean( "QuotationItemPlate" );
		bean.setPrice( price );

		if ( Len( id ) ) {
			var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
		}

		json.delete( "imageBase64" );

		bean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
		bean.setQuotationZone( super.service( "QuotationZone" ).get( json.quotationZone.id ) );

		bean.setQuantity( json.quantity );

		var product = super
			.fire(
				"Product.search",
				{
					categoryId = 22,
					lineId     = json.product.line.id,
					modelId    = json.product.model.id,
					finishId   = json.product.finish.id
				}
			)
			.getData();

		product = product[ 1 ];

		bean.setProduct( product );

		for ( var thisFruit in json.fruits._data ) {
			if ( IsNumeric( thisFruit.id ) ) {
				// update
				var fruitBean = super.fire( "QuotationItemFruit.get", [ thisFruit.id ] );
				//var action    = "QuotationItemFruit.update";
			} else {
				// create
				var fruitBean = super.bean( "QuotationItemFruit" );
				//var action    = "QuotationItemFruit.create";
			}

			var product = super.fire( "product.get", [ thisFruit.fruit.id ] );

			fruitBean.setFruit( product );
			//fruitBean.setQuotationItemId( thisId );
			fruitBean.setPosition( thisFruit.position );

			beanFruits.add( fruitBean );

			//super.fire( action, [ fruitBean ] );
		}

		bean.setFruits( beanFruits );		

		if ( !Len( id ) ) {
			messageId = "quotationItem.created";
			thisId    = super.fire( "quotationItem.create", [ bean ] )
		} else {
			messageId = "quotationItem.updated";
			thisId    = super.fire( "quotationItem.update", [ bean ] )
		}

		
		var files = super.fire( "File.search", { quotationItemId = thisId } );

		if ( Len( files.getData() ) ) {
			for ( var file in files.getData() ) {
				super.fire( "file.delete", { fileId = file.getId() } );
			}
		}

		var entity = super.bean( "Entity" );

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

		var quotationItemProductItems = super.fire( "quotationItemProductItem.list", { quotationItemId = thisId } );

		quotationItemProductItems.each( function( quotationItemProductItem ){
			super.fire( "quotationItemProductItem.delete", { "productItemId" = quotationItemProductItem.getId() } )
		} );

		var productItemsData = json.product.items._data;

		productItemsData.each( function( productItemRow ){
			var selectedValue = selectedValues = ArrayFilter( productItemRow.values, function( value ){
				return value.selected;
			} )

			if ( Len( selectedValue ) > 0 ) {
				selectedValue = selectedValue[ 1 ];

				var productItemBean = super.bean( "QuotationItemProductItem" );
				var productItem     = super.fire( "productItem.get", { "productItemId" = selectedValue.productItemId } );

				productItemBean.setQuotationItemId( thisId );
				productItemBean.setProductItem( productItem );
				productItemBean.setOrigin( productItem.getOrigin() );
				productItemBean.setLevel( productItemRow.level );
				// productItemBean.setId( thisId )

				super.fire( "quotationItemProductItem.create", [ productItemBean ] )
			}
		} );


		//var svc = super.service( "QuotationItem" );
		//dump( DESerializeJSON(SerializeJSON( svc.get( thisId ).getProduct().getItems() ) ));
		//dump(thisId);
		//abort;

		//TODO: move to service
		var hash = super.fire( "productHash.createHash", { "quotationItemId" = thisId } );

		if ( !IsNull( hash ) ) {
			bean.setHash( hash );
			bean.setId( thisId );
			super.fire( "quotationItem.update", [ bean ] );
		}
		
		var message = completeMessage( messageId );

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
