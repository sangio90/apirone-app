component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var memy   = super.getMementify();

		param rc.id = "";
		param rc.categoryId = "";
		param rc.quotationZoneId = "";

		params[ "typeId" ] = getTypeIdBySlug( rc.typeId );
		params[ "quotationId" ] = rc.id;
		params[ "orderBy" ] = [ { "field" = "quotationZonePosition.code", "dir" = "asc" } ];
		params[ "quotationZoneId" ] = Len( rc.quotationZoneId ) ? rc.quotationZoneId : null;

		var rows = super.fire( "QuotationItem.search", params );
		var data = ( memy.convertList( rows.getData() ) );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );
		

		event.setValue( "result", result );
	}

	function editArticle( event, rc, prc ){
		var data   = {}
		var result = super.getResult();
		//var params = super.paramsFromUrl();
		var memy     = super.getMementify();

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var parsedQuotationItemData = memy.convert( quotationItem, "editArticle" );

		data.append( { "quotationItem" = parsedQuotationItemData } );

		result.setData( data );
		event.setValue( "result", result );
	}

	function saveArticle( event, rc, prc ){
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";

		var result = super.getResult();

		var id   = json.quotationItem.id;

		if ( !Len( id ) ) {
			var bean = super.bean( "QuotationItem" );
		} else {
			var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
		}

		bean.setQuotation( super.service( "Quotation" ).get( json.id ) );
		bean.setQuotationZone( super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id ) );
		bean.setQuantity( json.quotationItem.quantity );
		bean.setArticle( super.fire( "Article.get", { articleId = json.quotationItem.article.id } ) );

		var price = super.bean( "QuotationItemPrice" );
		
		price.setDiscount1( 0 );
		price.setDiscount2( 0 );
		var method  = super.bean( "PriceMethod" );
		price.setMethod( method.setId( "F" ) );
		price.setAmount( Val( json.quotationItem.price.amount ) ? json.quotationItem.price.amount : 0 );
		var status  = super.bean( "Status" );
		bean.setStatus( status.setId( json.quotationItem.status.id ) );
		bean.setNote( json.quotationItem.note );

		bean.setPrice( price );

		if ( !Len( id ) ) {
			messageId = "quotationItem.created";
			thisId    = super.fire( "quotationItem.create", [ bean ] )
		} else {
			messageId = "quotationItem.updated";
			thisId    = super.fire( "quotationItem.update", [ bean ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { "id" = thisId } } );

		event.setValue( "result", result );
	}


	function listFruits( event, rc, prc ){
		
		var data   = [];
		var result = super.getResult();
		var memy   = super.getMementify();

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );
		var fruits = quotationItem.getFruits();

		fruits.each( function( fruit ){
			data.add( memy.convert( fruit, "editForPlace" ) );
		} );

		result.setData( data );
		event.setValue( "result", result );
	}	

	function editPlate( event, rc, prc ){
		
		var data   = {};
		var result = super.getResult();
		var memy   = super.getMementify();

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var parsedQuotationItemData = memy.convert( quotationItem, "editPlate" );

		data.append( {
			"quotationItem" = parsedQuotationItemData,
			"plate" = {}
		} );

		result.setData( data );
		event.setValue( "result", result );
	}

	function editSignage( event, rc, prc ){
		
		var data   = {};
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
		var memy     = super.getMementify();
		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var item = memy.convert( quotationItem, "edit" );
		item.product["category"] = memy.convert( quotationItem.getProduct().getCategory() );
		data.append( { "quotationItem" = item } );

		result.setData( data );
		event.setValue( "result", result );
	}

	function saveAccessory( event, rc, prc ){
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var status = super.bean( "Status" );
		var result = super.getResult();

		var id   = json.quotationItem.id;
		var type = json.type

		if ( !Len( id ) ) {
			var bean = super.bean( "QuotationItem" );
		} else {
			var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
		}

		bean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) ); //TODO: move to QuotationId
		bean.setQuotationZone( super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id ) );
		bean.setQuantity( json.quotationItem.quantity );

		bean.setSpecial( json.quotationItem.special );
		bean.setNote( json.quotationItem.note );
		bean.setStatus( status.setId( json.quotationItem.status.id ) );
		if ( !Len( id ) ) {
			json.quotationItem.id = lcase(createUUID());
		}

		if( Len( json.quotationItem?.position?.code ) ) {
			var position = populatePositionBean( json.quotationItem.position );
			bean.setPosition( position );
		} else  {
			bean.setPosition( null );
		}
		
		var price = getPricing( json );
		bean.setPrice( price );

		var product = super
			.fire(
				"Product.search",
				{
					lineId     = json.quotationItem.product.line.id,
					modelId    = json.quotationItem.product.model.id,
					categoryId = json.quotationItem.product.category.id,
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

		saveImage( imageBase64 = json.imageBase64, quotationItemId = thisId, typeId = "accessory" );

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

		if ( json.quotationItem.product.keyExists( "items" ) ) {
			var productItemsData = json.quotationItem.product.items._data;
			productItemsData.each( function( productItemRow ){
				var selectedValue = selectedValues = ArrayFilter( productItemRow.values, function( v ){
					return v.selected;
				} );

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
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { "id" = thisId } } );

		event.setValue( "result", result );
	}

	function saveSignage( event, rc, prc ){
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var status = super.bean( "Status" );
		var result = super.getResult();

		var id   = json.quotationItem.id;
		var type = json.type

		if ( !Len( id ) ) {
			var bean = super.bean( "QuotationItemSignage" );
		} else {
			var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
		}

		bean.setSpecial( json.quotationItem.special );
		bean.setNote( json.quotationItem.note );
		bean.setStatus( status.setId( json.quotationItem.status.id ) );
		if ( !Len( id ) ) {
			json.quotationItem.id = lcase(createUUID());
		}
		var price = getSignagePricing( json );
		bean.setPrice( price );

		if( Len( json.quotationItem?.position?.code ) ) {
			var position = populatePositionBean( json.quotationItem.position );
			bean.setPosition( position );
		} else  {
			bean.setPosition( null );
		}

		bean.setSignageConfigItem(
			super.service( "SignageConfigItem" ).get( json.quotationItem.signageConfigItem.id )
		);

		bean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
		bean.setQuotationZone( super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id ) );
		bean.setQuantity( json.quotationItem.quantity );

		if( Len( json.quotationItem?.position?.code ) ) {
			var position = populatePositionBean( json.quotationItem.position );
			bean.setPosition( position );
		} else  {
			bean.setPosition( null );
		}


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
		
		product = product[ 1 ];
		
		bean.setProduct( super.fire( "Product.get", { "productId" = product.getId() } ) );

		if ( !Len( id ) ) {
			messageId = "quotationItem.created";
			thisId    = super.fire( "quotationItem.create", [ bean ] )
		} else {
			messageId = "quotationItem.updated";
			thisId    = super.fire( "quotationItem.update", [ bean ] )
		}

		saveImage( imageBase64 = json.imageBase64, quotationItemId = thisId, typeId = "signage" );

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

		/*
		nel servizio
		var hash = super.fire( "productHash.createHash", { "quotationItemId" = thisId } );
		if ( !IsNull( hash ) ) {
			bean.setHash( hash );
			bean.setId( thisId );
			super.fire( "quotationItem.update", [ bean ] );
		}
		*/

		var message = completeMessage( messageId );
		
		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function savePlate( event, rc, prc ){
		
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";

		var result = super.getResult();
		var tmpDir = super.getTempDir();
		
		var status      = super.bean( "Status" );
		var zone        = super.bean( "QuotationZone" );
		var bean        = super.bean( "QuotationItemPlate" );
		var frame       = super.bean( "Frame" );
		var orientation = super.bean( "Orientation" );

		var beanFruits = [];

		var id = json.item.id;

		if ( Len( id ) ) {
			var bean = duplicate( super.fire( "QuotationItem.get", { quotationItemId = id } ) );
		}

		bean.setQuotation( super.fire( "Quotation.get", [ json.quotationId ] ) ); //TODO: move to QuotationId
		
		bean.setQuantity( json.item.quantity );
		bean.setStatus( status.setId( json.item.status.id ) );
		bean.setQuotationZone( zone.setId( json.item.quotationZone.id ) );
		bean.setSpecial( json.item.special );
		bean.setFrame( frame.setOrientation( orientation.setId( json.item.product.orientation.id ) ) );

		if( Len( json.item?.position?.code ) ) {
			var position = populatePositionBean( json.item.position );
			bean.setPosition( position );
		}

		var pricing = getPlatePricing( json );

		bean.setPrice( pricing );
		
		var product = super.fire( "Product.search",
				{
					categoryId = 22,
					lineId     = json.item.product.line.id,
					modelId    = json.item.product.model.id,
					finishId   = json.item.product.finish.id
				}
			).getData();

		product = product[ 1 ];

		bean.setProduct( product );

		for ( var thisFruit in json.item.fruits._data ) {

			var positions = json.positions[ thisFruit.id ];
			
			/*
				INFO:
				se id è numerico: è stato già salvato nel db
				se id è stringa: è stato agenerato da js per il dnd, record nuovo
			*/
			if ( IsNumeric( thisFruit.id ) ) {
				// update
				var fruitBean = super.fire( "QuotationItemFruit.get", [ thisFruit.id ] );
			} else {
				// create
				var fruitBean = super.bean( "QuotationItemFruit" );
			}

			var product = super.fire( "product.get", [ thisFruit.fruit.id ] );

			fruitBean.setFruit( product );
			fruitBean.setPositions( positions );

			var items = [];

			var fruitProductItemsData = thisFruit.items._data;

			fruitProductItemsData.each( function( productItemRow ){
				var selectedValue = selectedValues = ArrayFilter( productItemRow.values, function( value ){
					return value.selected;
				} )

				if ( Len( selectedValue ) > 0 ) {
					selectedValue = selectedValue[ 1 ];

					var productItemBean = super.bean( "QuotationItemProductItem" );
					var productItem     = super.fire( "productItem.get", { "productItemId" = selectedValue.productItemId } );

					//productItemBean.setQuotationItemFruitId( fruitBean.getId() );
					productItemBean.setProductItem( productItem );
					productItemBean.setOrigin( productItem.getOrigin() );
					productItemBean.setLevel( productItemRow.level );

					items.add( productItemBean );
				}
			} );
			
			fruitBean.setItems( items );

			beanFruits.add( fruitBean );

		}

		bean.setFruits( beanFruits );

		if ( !Len( id ) OR json.isClone ) {
			messageId = "quotationItem.created";
			thisId    = super.fire( "quotationItem.create", [ bean ] )
		} else {
			messageId = "quotationItem.updated";
			thisId    = super.fire( "quotationItem.update", [ bean ] )
		}

		saveImage( imageBase64 = json.imageBase64, quotationItemId = thisId, typeId = "plate" );

		var quotationItemProductItems = super.fire( "quotationItemProductItem.list", { quotationItemId = thisId });

		quotationItemProductItems.each( function( quotationItemProductItem ){
			super.fire( "quotationItemProductItem.delete", { "productItemId" = quotationItemProductItem.getId() } )
		} );

		var productItemsData = json.item.product.items._data;

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

	function fruitProductItems( event, rc, prc ){
		var result = super.getResult();
		var memny  = super.getMementify();
		
		/*
			INFO:
			se id numerico: è stato già salvato nel db
			se id stringa: è stato agenerato da js per il dnd, record nuovo
		*/
		if( IsNumeric( rc.id ) ) {
			var quotationItemFruitId = rc.id;

			var productItems = super.fire( "QuotationItemProductItem.list", { quotationItemFruitId = quotationItemFruitId } );

			var productItems = memny.convertList( productItems );
			
			result.setCount( Len( productItems ) );
			result.setData( productItems );

		} else {
			result.setCount( 0 );
			result.setData( [] );
		}

		event.setValue( "result", result );
	}

	function calculate( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content )

		if (rc.type == "signage") {
			var price = getSignagePricing( json );
		} elseif(rc.type == "plate") {
			var price = getPlatePricing( json );
		} else {
			var price = getPricing( json );
		}

		var memy = super.getMementify();
		var data = memy.convert( price );

		event.setValue( "result", data );
	}

	/*
		private methods
	*/

	private com.apirone.core.model.bean.QuotationItemPrice function getSignagePricing( required Struct data ){
		var json = arguments.data;

		var pricing = super.bean( "QuotationItemPrice" );
		var method  = super.bean( "PriceMethod" );

		var calculator = super.service( "PriceCalculator" );

		var lines = [];

		pricing.setQuotationItemId( json.quotationItem.id );
		pricing.setId( Val( json.quotationItem.price.id ) ? json.quotationItem.price.id : null );
		pricing.setQuantity( Val( json.quotationItem.quantity ) ? json.quotationItem.quantity : 1 );
		pricing.setDiscount1( Val( json.quotationItem.price.discount1 ) ? json.quotationItem.price.discount1 : 0 );
		pricing.setDiscount2( Val( json.quotationItem.price.discount2 ) ? json.quotationItem.price.discount2 : 0 );
		        
		pricing.setMethod( method.setId( json.quotationItem.price.method.id ) );
		
        if ( json.quotationItem.price.method.id EQ 'F' ) {
			pricing.setAmount( Val( json.quotationItem.price.total ) ? json.quotationItem.price.total : 0 );
		} else {
			pricing.setAmount( 0 );
		}

		/*
			signage price
		*/
		var productItemsIds = [];

		var product = json.quotationItem.product;

		for ( var item in json.quotationItem.product.items._data ) {
			for ( var value in item.values ) {
				if ( value.selected ) {
					productItemsIds.add( value.product_item_id );
				}
			}
		}

		var lettersQuantity = 0;
		for ( var signageRow in json.quotationItem.signageRows._data ) {
			lettersQuantity += Val( signageRow.charCount ) ? signageRow.charCount : 0;
		}
		var signagePrice = calculator.calculate(
			product.id,
			json.quotationItem.quantity,
			productItemsIds,
			lettersQuantity,
			json.quotationItem.signageConfigItem.id
		);
		var line = super.bean( "QuotationItemPriceLine" );

		line.setName( "Prezzo segnaletica" );
		line.setAmount( signagePrice.finalPrice );
		line.setCost( signagePrice.totalCost );

		lines.add( line );

		pricing.setLines( lines );

		return pricing;
	}

	/*
		private methods
	*/

	private com.apirone.core.model.bean.QuotationItemPrice function getPlatePricing( required Struct data ){
		
		var json = arguments.data;

		var pricing = super.bean( "QuotationItemPrice" );
		var method  = super.bean( "PriceMethod" );

		var calculator = super.service( "PriceCalculator" );

		var lines = [];

		pricing.setQuantity( Val( json.price.quantity ) ? json.item.quantity : 1 );
		pricing.setDiscount1( Val( json.price.discount1 ) ? json.price.discount1 : 0 );
		pricing.setDiscount2( Val( json.price.discount2 ) ? json.price.discount2 : 0 );
		        
		pricing.setMethod( method.setId( json.price.method.id ) );
		
        if ( pricing.isFixed() ) {
			pricing.setAmount( Val( json.price.total ) ? json.price.total : 0 );
		} else {
			pricing.setAmount( 0 );
		}

		/*
			plate price
		*/

		var productItemsIds = [];

		var product = json.item.product;

		for ( var item in product.items._data ) {
			for ( var value in item.values ) {
				if ( value.selected ) {
					productItemsIds.add( value.productItemId );
				}
			}
		}

		var platePrice = calculator.calculate(
			product.id,
			json.item.quantity,
			productItemsIds
		);

		var line = super.bean( "QuotationItemPriceLine" );

		line.setName( "Prezzo placca" );
		line.setAmount( platePrice.finalPrice );
		line.setCost( platePrice.totalCost );
		lines.add( line );


		/*
			fruits price
		*/

		for ( var fruit in json.item.fruits._data ) {
			var fruitItemsIds = [];
			
			var line = super.bean( "QuotationItemPriceLine" );

			for ( var item in fruit.items._data ) {
				for ( var value in item.values ) {
					if ( value.selected ) {
						fruitItemsIds.add( value.productItemId );
					}
				}
			}

			var fruitPrice = calculator.calculate( fruit.fruit.id, 1, fruitItemsIds );

			line.setName( "#fruit.fruit?.name#" );
			line.setAmount( fruitPrice.finalPrice );
			line.setCost( fruitPrice.totalCost );
			lines.add( line );
		}

		pricing.setLines( lines );

		return pricing;
	}

	/*
		private methods
	*/

	private com.apirone.core.model.bean.QuotationItemPrice function getPricing( required Struct data ){

		//var result = super.getResult();
		
		var json = arguments.data;

		var pricing = super.bean( "QuotationItemPrice" );
		var method  = super.bean( "PriceMethod" );

		var calculator = super.service( "PriceCalculator" );

		var lines = [];

		pricing.setQuotationItemId( json.quotationItem.id );
		pricing.setId( Val( json.quotationItem.price.id ) ? json.quotationItem.price.id : null );
		pricing.setQuantity( Val( json.quotationItem.quantity ) ? json.quotationItem.quantity : 1 );
		pricing.setDiscount1( Val( json.quotationItem.price.discount1 ) ? json.quotationItem.price.discount1 : 0 );
		pricing.setDiscount2( Val( json.quotationItem.price.discount2 ) ? json.quotationItem.price.discount2 : 0 );
		        
		pricing.setMethod( method.setId( json.quotationItem.price.method.id ) );
		
        if ( json.quotationItem.price.method.id EQ 'F' ) {
			pricing.setAmount( Val( json.quotationItem.price.total ) ? json.quotationItem.price.total : 0 );
		} else {
			pricing.setAmount( 0 );
		}

		/*
			price
		*/

		var productItemsIds = [];

		var product = json.quotationItem.product;
		if ( product.keyExists( "items" ) ) {
			for ( var item in product.items._data ) {
				for ( var value in item.values ) {
					if ( value.selected ) {
						productItemsIds.add( value.product_item_id );
					}
				}
			}
		}

		var price = calculator.calculate(
			product.id,
			json.quotationItem.quantity,
			productItemsIds
		);

		var line = super.bean( "QuotationItemPriceLine" );

		line.setName( "Prezzo base" );
		line.setAmount( price.finalPrice );
		line.setCost( price.totalCost );

		lines.add( line );

		pricing.setLines( lines );

		return pricing;
	}
	
	private com.apirone.core.model.bean.QuotationItemPrice function populatePriceItem( data ){

		var method = super.bean( "PriceMethod" );
		var bean = super.bean( "QuotationItemPrice" );

		var lines = [];
		var thisLines = data.price.keyExists("lines") ? data.price.lines : [];

		bean.setAmount( data.price.total );
		bean.setDiscount1( Len( data.price?.discount1 ) ? data.price?.discount1 : 0 );
		bean.setDiscount2( Len( data.price?.discount2 ) ? data.price?.discount2 : 0 );
		bean.setMethod( method.setId( data.price.method.id ) );

		for( var thisLine in thisLines ) {
			var priceLine  = super.bean( "QuotationItemPriceLine" );
			priceLine.setName( thisLine.name );
			priceLine.setAmount( thisLine.amount );
			
			lines.add( priceLine );
		}

		bean.setLines( lines );

		return bean;

	}

	private Struct function populatePositionBean( 
			required Struct data
		){
		
		var position = super.bean( "QuotationZonePosition" );

		position.setId( data.id );
		position.setCode( data.code );
		//position.setName( data.name );

		return position;

	}

	private Struct function saveImage( 
			required String imageBase64, 
			required String quotationItemId,
			required String typeId
		){
		
		var tmpDir = getTempDir();

		// INFO: se uso il get qui il servizio crea la cache senza immagine
		// che sarà vuota quando viene serializzata
		//var item = service("QuotationItem").get( arguments.quotationItemId );

		//var type = "accessory";

		/*
		if( IsInstanceOf( item, "com.apirone.core.model.bean.QuotationItemPlate" ) ){
			type = "plate";
		}

		if( IsInstanceOf( item, "com.apirone.core.model.bean.QuotationItemSignage" ) ){
			type = "signage";
		}
		*/

		var fileName   = "preview_" & arguments.typeId & "_id_" & arguments.quotationItemId & ".png";
		var filePath   = tmpDir & "/" & fileName;
		var binaryData = ToBinary( arguments.imageBase64 );

		FileWrite( filePath, binaryData );

		var files = super.fire( "File.search", { quotationItemId = arguments.quotationItemId } );
		
		if ( Len( files.getData() ) ) {
			for ( var file in files.getData() ) {
				super.fire( "File.delete", { fileId = file.getId() } );
			}
		}

		var entity = super.bean( "Entity" );
		
		entity.setKey( "quotationItem.id" );
		entity.setValue( arguments.quotationItemId );

		var fileId = super.fire(
			"file.create",
			{
				filePath = filePath,
				typeId   = "default",
				kindId   = "quotationItem",
				entity   = entity
			}
		);

		var result = {	
			"fileId"   = fileId,
			"fileName" = fileName,
			"type" = arguments.typeId
		};

		return result;

	}

	private String function getTypeIdBySlug( 
			required String slug
		){

		var params = {
			"plate"     = "PLA",
			"accessory" = "ACC",
			"signage"   = "SEG",
			"article"   = "ART"
		}

		return params[ arguments.slug ];		

	}

}
