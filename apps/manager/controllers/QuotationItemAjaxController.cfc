component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var memy   = super.getMementify();

		param rc.id = "";
		param rc.categoryId = "";
		param rc.quotationZoneId = "";

		if( rc.typeId == "article" ) {

		} else {

			params[ "typeId" ] = getTypeIdBySlug( rc.typeId );
			params[ "quotationId" ] = rc.id;
			params[ "quotationZoneId" ] = Len( rc.quotationZoneId ) ? rc.quotationZoneId : null;

			var rows = super.fire( "QuotationItem.search", params );

			var data = ( memy.convertList( rows.getData() ) );

			result.setTotal( rows.getTotal() );
			result.setCount( rows.getCount() );
			result.setData( data );

		}
		

		event.setValue( "result", result );
	}

	function editArticle( event, rc, prc ){
		var data   = {}
		var result = super.getResult();
		//var params = super.paramsFromUrl();
		var memy     = super.getMementify();

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var parsedQuotationItemData = memy.convert( quotationItem, "edit" );

		data.append( { "quotationItem" = parsedQuotationItemData } );

		result.setData( data );
		event.setValue( "result", result );
	}

	function saveArticle( event, rc, prc ){
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";
		//var texts     = [];

		var result = super.getResult();

		var id   = json.quotationItem.id;
		//var type = json.type;

		if ( !Len( id ) ) {
			var bean = super.bean( "QuotationItem" );
		} else {
			var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
		}

		bean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
		bean.setQuotationZone( super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id ) );
		bean.setQuantity( json.quotationItem.quantity );

		var price = populatePriceItem( json );
		bean.setPrice( price );

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { "id" = thisId } } );

		event.setValue( "result", result );
	}


	function listFruits( event, rc, prc ){
		
		var data   = {};
		var result = super.getResult();
		var memy   = super.getMementify();

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );
		var fruits = quotationItem.getFruits();

		/*
		quotationItem.getFruits().each( function( fruit ){
			data.append( memy.convert( fruit ) );
		} );
		*/

		//var parsedQuotationItemData = memy.convert( , "edit" );

		result.setData( fruits );
		event.setValue( "result", result );
	}	

	function editPlate( event, rc, prc ){
		
		var data   = {};
		var result = super.getResult();
		var memy   = super.getMementify();

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var parsedQuotationItemData = memy.convert( quotationItem, "edit" );

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
		var params = super.paramsFromUrl();
		var mm     = super.getMementify();


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

		var id   = json.quotationItem.id;
		var type = json.type

		if ( !Len( id ) ) {
			var bean = super.bean( "QuotationItem" );
		} else {
			var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
		}

		bean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
		bean.setQuotationZone( super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id ) );
		bean.setQuantity( json.quotationItem.quantity );

		var price = populatePriceItem( json );
		bean.setPrice( price );

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

		saveImage( imageBase64 = json.imageBase64, quotationItemId = thisId );

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

		var hash = super.fire( "productHash.createHash", { "quotationItemId" = thisId } );
		if ( !IsNull( hash ) ) {
			bean.setHash( hash );
			bean.setId( thisId );
			super.fire( "quotationItem.update", [ bean ] );
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

		var result = super.getResult();

		var id   = json.quotationItem.id;
		var type = json.type
			
		if ( !Len( id ) ) {
			var bean = super.bean( "QuotationItemSignage" );
		} else {
			var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
		}

		var price = populatePriceItem( json );
		bean.setPrice( price );

		bean.setSignageConfigItem(
			super.service( "SignageConfigItem" ).get( json.quotationItem.signageConfigItem.id )
		);

		bean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
		bean.setQuotationZone( super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id ) );
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
		
		product = product[ 1 ];
		
		bean.setProduct( super.fire( "Product.get", { "productId" = product.getId() } ) );

		if ( !Len( id ) ) {
			messageId = "quotationItem.created";
			thisId    = super.fire( "quotationItem.create", [ bean ] )
		} else {
			messageId = "quotationItem.updated";
			thisId    = super.fire( "quotationItem.update", [ bean ] )
		}

		saveImage( imageBase64 = json.imageBase64, quotationItemId = thisId );

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

	function savePlate( event, rc, prc ){
		
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";

		var result = super.getResult();
		var tmpDir = super.getTempDir();
		
		var bean   = super.bean( "QuotationItemPlate" );
		var status = super.bean( "Status" );

		var beanFruits = [];

		var id = json.item.id;

		if ( Len( id ) ) {
			var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
		}

		bean.setQuotation( super.fire( "Quotation.get", [ json.quotationId ] ) ); //TODO: move to QuotationId
		bean.setQuantity( json.item.quantity );
		bean.setStatus( status.setId( json.item.status.id ) );
		bean.setSpecial( json.item.special );

		var pricing = getPricing( json );
		
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

		if ( !Len( id ) OR json.isClone ) {
			messageId = "quotationItem.created";
			thisId    = super.fire( "quotationItem.create", [ bean ] )
		} else {
			messageId = "quotationItem.updated";
			thisId    = super.fire( "quotationItem.update", [ bean ] )
		}

		saveImage( imageBase64 = json.imageBase64, quotationItemId = thisId );

		var quotationItemProductItems = super.fire( "quotationItemProductItem.list", { quotationItemId = thisId } );

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

		/*
		//TODO: move to service
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

	function calculate( event, rc, prc ){

		var json = DeserializeJSON( GetHTTPRequestData().content )

		var price = getPricing( json );

		var memy = super.getMementify();
		var data = memy.convert( price );

		event.setValue( "result", data );
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

		pricing.setQuantity( Val( json.pricing.quantity ) ? json.pricing.quantity : 1 );
		pricing.setDiscount1( Val( json.pricing.discount1 ) ? json.pricing.discount1 : 0 );
		pricing.setDiscount2( Val( json.pricing.discount2 ) ? json.pricing.discount2 : 0 );
		        
		pricing.setMethod( method.setId( json.pricing.method.id ) );
		
        if ( pricing.isFixed() ) {
			pricing.setAmount( Val( json.total ) ? json.total : 0 );
		} else {
			pricing.setAmount( 0 );
		}

		/*
			plate price
		*/

		var productItemsIds = [];

		//dump(json.data.product);
		//abort;

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
			json.pricing.quantity,
			productItemsIds
		);

		var line = super.bean( "QuotationItemPriceLine" );

		line.setName( "Prezzo placca" );
		line.setAmount( platePrice );

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
			line.setAmount( fruitPrice );

			lines.add( line );
		}

		pricing.setLines( lines );

		return pricing;
	}	
	
	private com.apirone.core.model.bean.QuotationItemPrice function populatePriceItem( data ){

		var method = super.bean( "PriceMethod" );
		var bean = super.bean( "QuotationItemPrice" );

		var lines = [];
		var thisLines = data.pricing.keyExists("lines") ? data.pricing.lines : [];

		bean.setAmount( data.pricing.total );
		bean.setDiscount1( Len( data.pricing?.discount1 ) ? data.pricing?.discount1 : 0 );
		bean.setDiscount2( Len( data.pricing?.discount2 ) ? data.pricing?.discount2 : 0 );
		bean.setMethod( method.setId( data.pricing.method.id ) );

		for( var thisLine in thisLines ) {
			var priceLine  = super.bean( "QuotationItemPriceLine" );
			priceLine.setName( thisLine.name );
			priceLine.setAmount( thisLine.amount );
			
			lines.add( priceLine );
		}

		bean.setLines( lines );

		return bean;

	}

	private Struct function saveImage( 
			required String imageBase64, 
			required String quotationItemId,
		){
		
		var tmpDir = getTempDir();

		var item = service("QuotationItem").get( arguments.quotationItemId );

		var type = "accessory";

		if( IsInstanceOf( item, "com.apirone.core.model.bean.QuotationItemPlate" ) ){
			type = "plate";
		}

		if( IsInstanceOf( item, "com.apirone.core.model.bean.QuotationItemSignage" ) ){
			type = "signage";
		}

		var fileName   = "preview_" & type & "_id_" & arguments.quotationItemId & ".png";
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
			"type" = type
		};

		return result;

	}

	private String function getTypeIdBySlug( 
			required String slug
		){

		var params = {
			"plate"     = "PLA",
			"accessory" = "ACC",
			"signage"   = "SIG"
		}

		return params[ arguments.slug ];		

	}

}
