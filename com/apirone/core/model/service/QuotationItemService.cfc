component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemDAO";
	property name="quotationItemFruitService" inject="QuotationItemFruitService";
	property name="quotationItemPriceService" inject="QuotationItemPriceService";
	property name="QuotationService" inject="QuotationService";
	property name="QuotationZoneService" inject="QuotationZoneService";
	property name="QuotationItemProductItemService" inject="QuotationItemProductItemService";
	property name="ProductService" inject="ProductService";
	property name="StatusService" inject="StatusService";
	property name="ArticleService" inject="ArticleService";
	property name="ProductHashService" inject="ProductHashService";
	property name="SignageConfigItemService" inject="SignageConfigItemService";
	property name="FileService" inject="FileService";
	property name="QuotationItemSignageRowService" inject="QuotationItemSignageRowService";
	property name="QuotationZonePositionService" inject="QuotationZonePositionService";
	property name="QuotationItemPositionService" inject="QuotationItemPositionService";
	property name="LookupService" inject="LookupService";

	property name="cacheScope" type="String" default="QuotationItem.bean";

	public com.apirone.core.model.bean.QuotationItem function get( required String quotationItemId, Boolean useCache = true ){
		var cm    = getCacheManager();
		if (useCache) {
			var cache = cm.get( getCacheScope(), arguments.quotationItemId );

			if ( cache.status ) {
				return cache.data;
			}
		}

		var bean = build( arguments.quotationItemId );

		cm.put(
			getCacheScope(),
			arguments.quotationItemId,
			bean
		);

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	//{26 marzo 2026} aggiunto parametro useCache = false perche durante la procedura di quotationItemAjaxController.updateAllPrices la cache condizionava in maniera errata il calcolo
	// vedi get()
	public com.apirone.core.model.bean.Result function search(
		String str,
		String mode,
		Boolean useCache = true,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotation.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );
		var useCache = arguments.useCache;

		records.each( function( record ) {
			var quotationItem = get( quotationItemId = record.quotation_item_id, useCache = useCache );
			if ( IsNull( mode ) ) {
				rows.add( quotationItem );
			} else {
				if ( mode == "plate" ) {
					if ( IsInstanceOf( quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" ) ) {
						rows.add( quotationItem );
					}
				} else {
					if ( !IsInstanceOf( quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" ) ) {
						rows.add( quotationItem );
					}
				}
			}
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String quotationItemId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemId = arguments.quotationItemId } );
		getDao().delete( arguments.quotationItemId );

		transaction {
			try {
				var cm = getCacheManager();
				getDao().delete( arguments.quotationItemId );
				cm.remove( getCacheScope(), arguments.quotationItemId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItem" );
				outcome.setMessage( "Cannot delete quotation item [#arguments.quotationItemId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItem quotationItem ){

		transaction {

			arguments.quotationItem = ensurePosition( arguments.quotationItem );

			var newId = getDao().insert( arguments.quotationItem );

			if ( IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" ) ) {
				for ( var thisFruit in arguments.quotationItem.getFruits() ) {
					thisFruit.setQuotationItemId( newId );
					thisFruit.setId(null)
					getQuotationItemFruitService().create( thisFruit );
				}
			}

			var price = arguments.quotationItem.getPrice();
			price.setQuotationItemId( newId );
			getQuotationItemPriceService().create( price );

			if ( isNull( arguments.quotationItem.getArticle() ) ) {
				var hash = getProductHashService().createHash( newId );
				if ( !IsNull( hash ) ) {
					updateHash( newId, hash );
				}
			}

			if (isNull(quotationItem.getArticle())) {
				var quotationItemQuantity = arguments.quotationItem.getQuantity();
				if (quotationItemQuantity > 0) {
					for (var i = 1; i <= quotationItemQuantity; i++) {
						var position = super.bean("QuotationItemPosition");
						position.setQuotationItemId(newId);
						getQuotationItemPositionService().create(position);
					}
				}
			}

		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItem quotationItem ){

		var oldBean = get( arguments.quotationItem.getId() );

		if ( IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" ) ) {
			var fruitIdsToDeleted = [];

			for ( var thisFruit in oldBean.getFruits() ) {
				var found = false;
				for ( var newFruit in arguments.quotationItem.getFruits() ) {
					if ( !IsNull( thisFruit.getId() ) && thisFruit.getId() == newFruit.getId() ) {
						found = true;
						break;
					}
				}
				if ( !found ) {
					fruitIdsToDeleted.add( thisFruit.getId() );
				}
			}
		}

		transaction {

			arguments.quotationItem = ensurePosition( arguments.quotationItem );

			getDao().update( arguments.quotationItem );

			super.getCacheManager().remove( getCacheScope(), arguments.quotationItem.getId() );

			if ( IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" ) ) {
				for( var thisFruitId in fruitIdsToDeleted ) {
					getQuotationItemFruitService().delete( thisFruitId );
				}

				for ( var thisFruit in arguments.quotationItem.getFruits() ) {
					if ( IsNull( thisFruit.getId() ) || thisFruit.getId() == "" ) {
						thisFruit.setQuotationItemId( arguments.quotationItem.getId() );
						getQuotationItemFruitService().create( thisFruit );
					} else {
						getQuotationItemFruitService().update( thisFruit );
					}
				}
			}

			if ( !IsNull( arguments.quotationItem.getPrice() ) ) {

				var current = getQuotationItemPriceService().getByQuotationItemId( arguments.quotationItem.getId() );

				arguments.quotationItem.getPrice().setId( current.getId() );
				arguments.quotationItem.getPrice().setQuotationItemId( arguments.quotationItem.getId() );

				var price = arguments.quotationItem.getPrice();
				getQuotationItemPriceService().update( price );
			}

			if ( isNull( arguments.quotationItem.getArticle() ) ) {
				var hash = getProductHashService().createHash( arguments.quotationItem.getId() );
				if ( !IsNull( hash ) ) {
					updateHash( arguments.quotationItem.getId(), hash );
				}

				var quotationItemQuantity = arguments.quotationItem.getQuantity();
				var countItemPositions = arguments.quotationItem.getPositions();
				if (isNull(countItemPositions)) {
					countItemPositions = 0;
				} else {
					countItemPositions = countItemPositions.len();
				}

				if (quotationItemQuantity > countItemPositions) {
					for (var i = countItemPositions + 1; i <= quotationItemQuantity; i++) {
						var position = super.bean("QuotationItemPosition");
						position.setQuotationItemId(arguments.quotationItem.getId());
						getQuotationItemPositionService().create(position);
					}
				}
				// Logica cancellata provvisoriamente, ora se riduco quantita lo gestisco lato controller, sara possibile eliminare (ridurre qta) solo dalla mappa.
				// else if (quotationItemQuantity < maxSequenceQuotationItemPosition) {
				// 	for (var i = quotationItemQuantity + 1; i <= maxSequenceQuotationItemPosition; i++) {
				// 		var positionToDelete = getQuotationItemPositionService().list( quotationItemId = arguments.quotationItem.getId(), sequence = i );
				// 		if (Len(positionToDelete) > 0) {
				// 			getQuotationItemPositionService().delete(positionToDelete[1].getId());
				// 		}
				// 	}
				// }
			}

		}

		return arguments.quotationItem.getId();
	}


	public Boolean function updateHash( required String quotationItemId, required String hash ){
		getDao().updateHash( quotationItemId, hash );
		super.getCacheManager().remove( getCacheScope(), arguments.quotationItemId );
		return true;
	}

	/**
	 * Ensure quotation item position is created and linked when needed.
	 */
	private com.apirone.core.model.bean.QuotationItem function ensurePosition( required com.apirone.core.model.bean.QuotationItem quotationItem ){

		if ( !IsNull( arguments.quotationItem.getPosition() ) ) {
			if ( Len( arguments.quotationItem.getPosition().getCode() ) ) {

				var position = arguments.quotationItem.getPosition();

				if ( IsNull( position.getId() ) OR !Len( position.getId() ) ) {

					position.setZoneId( arguments.quotationItem.getQuotationZone().getId() );
					var newPositionId = getQuotationZonePositionService().create( position );
					arguments.quotationItem.getPosition().setId( newPositionId );
				}
			}
		}

		return arguments.quotationItem;
	}

	private com.apirone.core.model.bean.QuotationItem function build( required String quotationItemId ){
		var record = getDao().read( arguments.quotationItemId );
		var fruits = getQuotationItemFruitService().list( quotationItemId = arguments.quotationItemId )
		if ( record.recordCount ) {

			var pricing = super.bean( "QuotationItemPrice" );
			var priceMethod = super.bean( "PriceMethod" );

			if ( fruits.len() > 0 ) {
				arraySort(fruits, function(a, b) {
					return a.getPositions()[1].order - b.getPositions()[1].order;
				});
				var bean = super.bean( "QuotationItemPlate" );
				var frame = super.bean( "Frame" );

				bean.setFruits( fruits )

				frame.setOrientation( getLookupService().get( "orientation", record.orientation_id ) );
				bean.setFrame( frame );

			} else {

				if ( Len( record.signage_config_item_id ) ) {
					var bean = super.bean( "QuotationItemSignage" );
				} else {
					var bean = super.bean( "QuotationItem" );
				}

			}

			var pricing = getQuotationItemPriceService().getByQuotationItemId( quotationItemId = arguments.quotationItemId );
			bean.setPrice( pricing );

			bean.setId( record.quotation_item_id );
			bean.setQuantity( record.quantity );
			bean.setCreatedAt( record.created_at );

			bean.setQuotation( getQuotationService().get( record.quotation_id ) );
			//bean.setPrice( pricing );

			if ( Len( record.product_id ) ) {
				bean.setProduct( getProductService().get( record.product_id ) );
			}

			if ( Len( record.status_id ) ) {
				bean.setStatus( getStatusService().get( record.status_id ) );
			}

			if ( Len( record.article_id ) ) {
				bean.setArticle( getArticleService().get( record.article_id ) );
			}

			bean.setQuotationZone(
				IsNull( record.quotation_zone_id ) ? NullValue() : getQuotationZoneService().get(
					record.quotation_zone_id
				)
			);

			if ( Len( record.signage_config_item_id ) ) {
				bean.setSignageConfigItem( getSignageConfigItemService().get( record.signage_config_item_id ) );

				if ( record.char_count ) {
					bean.getSignageConfigItem().setCharCount( record.char_count );
				}
				if ( record.height_in_pixel ) {
					bean.getSignageConfigItem().setHeightInPixel( record.height_in_pixel );
				}
				if ( record.row_count ) {
					bean.getSignageConfigItem().setRowCount( record.row_count );
				}

				var signageRows = getQuotationItemSignageRowService().list( quotationItemId = quotationItemId );
				bean.setSignageRows( signageRows );
			}

			var images = getFileService().list( quotationItemId = record.quotation_item_id );

			if ( Len( images ) ) {
				bean.setImage( images[ 1 ] );
			}

			var items = getQuotationItemProductItemService().list( quotationItemId = quotationItemId );

			if ( Len( items ) ) {
				bean.setItems( items );
			}

			bean.setNote( record.note );
			bean.setHash( record.hash );
			bean.setSpecial( BooleanFormat( Val( record.special ) ) );
			bean.setCustomImage( BooleanFormat( Val( record.custom_image ) ) );

			if( Len( record.quotation_zone_position_id ) ) {
				bean.setPosition( getQuotationZonePositionService().get( record.quotation_zone_position_id ) );
			}
			var quotationItemPositions = getQuotationItemPositionService().list( quotationItemId = arguments.quotationItemId );
			if ( Len( quotationItemPositions ) ) {
				bean.setPositions( quotationItemPositions );
			}
			return bean;
		}

		return NullValue();
	}

	public com.apirone.core.model.bean.QuotationItemPrice function getPlatePricing( required Struct data ){

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

		var quotationItem = null;
		if (json.item.id != "") {
			quotationItem = super.service( "QuotationItem" ).get( json.item.id );
		}

		var quotation = null;
		if (json.quotationId != "") {
			var quotation = super.service( "Quotation" ).get( json.quotationId );
		}

		var platePrice = calculator.calculate(
			product.id,
			json.item.quantity,
			json.item.quotationZone.id,
			productItemsIds,
			0,
			0,
			quotation,
			quotationItem
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

			var fruitPrice = calculator.calculate(
				fruit.fruit.id,
				1,
				json.item.quotationZone.id,
				fruitItemsIds,
				0,
				0,
				quotation,
				quotationItem
			);

			line.setName( "#fruit.fruit?.name#" );
			line.setAmount( fruitPrice.finalPrice );
			line.setCost( fruitPrice.totalCost );
			lines.add( line );
		}

		pricing.setLines( lines );

		return pricing;
	}

	public com.apirone.core.model.bean.QuotationItemPrice function getSignagePricing( required Struct data ){
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

		var lettersQuantity = 0;
		for ( var signageRow in json.quotationItem.signageRows._data ) {
			lettersQuantity += Val( signageRow.charCount ) ? signageRow.charCount : 0;
		}

		var quotation = getQuotationService().get( json.quotationId )
		var quotationItem = !isNull(json.quotationItem.id) && json.quotationItem.id != '' ? get( json.quotationItem.id ) : null

		var signagePrice = calculator.calculate(
			product.id,
			json.quotationItem.quantity,
			json.quotationItem.quotationZone.id,
			productItemsIds,
			lettersQuantity,
			json.quotationItem.signageConfigItem.id,
			quotation,
			quotationItem
		);
		var line = super.bean( "QuotationItemPriceLine" );

		line.setName( "Prezzo segnaletica" );
		line.setAmount( signagePrice.finalPrice );
		line.setCost( signagePrice.totalCost );

		lines.add( line );

		pricing.setLines( lines );

		return pricing;
	}

	public com.apirone.core.model.bean.QuotationItemPrice function getPricing( required Struct data ){
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

		var quotation = getQuotationService().get( json.quotationId )
		var quotationItem = !isNull(json.quotationItem.id) && json.quotationItem.id != '' ? get( json.quotationItem.id ) : null

		var price = calculator.calculate(
			product.id,
			json.quotationItem.quantity,
			json.quotationItem.quotationZone.id,
			productItemsIds,
			0,
			0,
			quotation,
			quotationItem
		);

		var line = super.bean( "QuotationItemPriceLine" );

		line.setName( "Prezzo base" );
		line.setAmount( price.finalPrice );
		line.setCost( price.totalCost );

		lines.add( line );

		pricing.setLines( lines );

		return pricing;
	}

	public function getAltreRigheByQuotationLineIdAndFinishId(
		required String quotationItemId,
		required String quotationId,
		required String lineId,
		required String finishId
	){
		if ( IsNull( quotationId ) ) {
			return [];
		}
		return getDao().getAltreRigheByQuotationLineIdAndFinishId(argumentCollection = arguments);
	}

	public function getAltreRigheByQuotationAndProductId(
		required String quotationItemId,
		required String quotationId,
		required String productId
	){
		if ( IsNull( quotationId ) ) {
			return [];
		}
		return getDao().getAltreRigheByQuotationAndProductId(argumentCollection = arguments);
	}

	public function aggiornaPrezzoAltriArticoliByQuotationIdLineIdFinishId(
		required String quotationItemId,
		required String quotationId,
		required String lineId,
		required String finishId
	){
		var rows = this.getAltreRigheByQuotationLineIdAndFinishId(
			"quotationItemId" = quotationItemId,
			"quotationId" = quotationId,
			"lineId" = lineId,
			"finishId" = finishId
		)

		for (var row in rows) {
			var data = {}
			var quotationItem = get( quotationItemId = row.quotation_item_id );
			if (
				!IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemPlate") &&
				!IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemSignage")
			) {
				continue;
			}

			aggiornaPrezzo(quotationItem)
		}
	}

	public function aggiornaPrezzoAltriArticoliByQuotationIdAndProductId(
		required String quotationItemId,
		required String quotationId,
		required String productId
	){
		var rows = this.getAltreRigheByQuotationAndProductId(
			"quotationItemId" = quotationItemId,
			"quotationId" = quotationId,
			"productId" = productId
		)

		for (var row in rows) {
			var data = {}
			var quotationItem = get( quotationItemId = row.quotation_item_id );
			if (
				IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemPlate") ||
				IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemSignage") ||
				!isNull(quotationItem.getArticle())
			) {
				continue;
			}

			aggiornaPrezzo(quotationItem)
		}
	}

	public function aggiornaPrezzo( required quotationItem )
	{
		if (!isNull(quotationItem.getArticle())) {
			return false;
		}
		var quotationId = quotationItem.getQuotation().getId()
		var productId = quotationItem.getProduct().getId();
		var quantity = quotationItem.getQuantity();
		var productItemIds = [];
		for (var item in quotationItem.getItems()) {
			productItemIds.append(item.getProductItem().getId())
		}

		//questa parte serve per replicare le strutture dati che si aspettano getSignagePricing e la getPlatePricing quando chiamate dal client
		if (IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemPlate")) {
			var json =
			{
				"quotationId": "",
				"price": {
					"quantity": 0,
					"discount1": 0,
					"discount2": 0,
					"total": 0,
					"method": { "id": "" }
				},
				"item": {
					"id": "",
					"quantity": 0,
					"product": {
						"id": "",
						"items": { "_data": [] }
					},
					"quotationZone": {
						"id": ""
					},
					"fruits": { "_data": [] }
				}
			}
			json.quotationId = quotationId;
			json.item.id = quotationItem.getId();
			json.item.quotationZone.id = quotationItem.getQuotationZone().getId();
			json.item.quantity = quantity;
			if (!isNull(quotationItem.getPrice())) {
				json.price.id = quotationItem.getPrice().getId();
				json.price.discount1 = quotationItem.getPrice().getDiscount1();
				json.price.discount2 = quotationItem.getPrice().getDiscount2();
				json.price.method.id = quotationItem.getPrice().getMethod().getId();
				json.price.total = quotationItem.getPrice().getMethod().getId() == "F" ? quotationItem.getPrice().getAmount() : 0;
			}
			json.item.product.id = productId;
			for (productItemId in productItemIds) {
				json.item.product.items._data.append({
					values = [
						{ selected = true, productItemId = productItemId }
					]
				});
			}
			var fruits = quotationItem.getFruits();
			for (var fruit in fruits) {
				var fruitItems = []

				for (fruitItem in fruit.getItems()) {
					fruitItems.append({
						values = [
							{ selected = true, productItemId = fruitItem.getProductItem().getId() }
						]
					})
				}
				json.item.fruits._data.append({
					"fruit": {
						"name": fruit.getFruit().getName(),
						"id": fruit.getFruit().getId()
					},
					"fruitId": fruit.getId(),
					"items": { "_data": fruitItems }
				});
			}
			var price = getPlatePricing(json)
		}

		if (IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemSignage")) {
			json = {
				"quotationId": "",
				"quotationItem": {
					"id": "",
					"quantity": 0,
					"price": {
						"id": 0,
						"discount1": 0,
						"discount2": 0,
						"method": { "id": "F" },
						"total": 0
					},
					"quotationZone": {
						"id": ""
					},
					"product": {
						"id": "",
					"items": { "_data": [] }
					},
					"signageRows": { "_data": [] },
					"signageConfigItem": { "id": 0 }
				}
			}

			json.quotationId = quotationId;
			json.quotationItem.id = quotationItem.getId()
			json.quotationItem.quotationZone.id = quotationItem.getQuotationZone().getId()
			json.quotationItem.quantity = quantity
			if (!isNull(quotationItem.getPrice())) {
				json.quotationItem.price.id = quotationItem.getPrice().getId();
				json.quotationItem.price.discount1 = quotationItem.getPrice().getDiscount1();
				json.quotationItem.price.discount2 = quotationItem.getPrice().getDiscount2();
				json.quotationItem.price.method.id = quotationItem.getPrice().getMethod().getId();
				json.quotationItem.price.total = quotationItem.getPrice().getMethod().getId() == "F" ? quotationItem.getPrice().getAmount() : 0;
			}
			json.quotationItem.product.id = productId;
			for (productItemId in productItemIds) {
				json.quotationItem.product.items._data.append({
					values = [
						{ selected = true, product_item_id = productItemId }
					]
				});
			}

			json.quotationItem.signageConfigItem.id = quotationItem.getSignageConfigItem().getId()
			for ( var signageRow in quotationItem.getSignageRows() ) {
				json.quotationItem.signageRows._data.append({ charCount = signageRow.getCharCount() });
			}
			var price = getSignagePricing(json)
		} elseif (isNull(quotationItem.getArticle()) && !IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemPlate")) {
			json = {
				"quotationId": "",
				"quotationItem": {
					"id": "",
					"quantity": 0,
					"price": {
						"id": 0,
						"discount1": 0,
						"discount2": 0,
						"method": { "id": "F" },
						"total": 0
					},
					"quotationZone": {
						"id": ""
					},
					"product": {
						"id": "",
					"items": { "_data": [] }
					}
				}
			}

			json.quotationId = quotationId;
			json.quotationItem.id = quotationItem.getId()
			json.quotationItem.quotationZone.id = quotationItem.getQuotationZone().getId()
			json.quotationItem.quantity = quantity
			if (!isNull(quotationItem.getPrice())) {
				json.quotationItem.price.id = quotationItem.getPrice().getId();
				json.quotationItem.price.discount1 = quotationItem.getPrice().getDiscount1();
				json.quotationItem.price.discount2 = quotationItem.getPrice().getDiscount2();
				json.quotationItem.price.method.id = quotationItem.getPrice().getMethod().getId();
				json.quotationItem.price.total = quotationItem.getPrice().getMethod().getId() == "F" ? quotationItem.getPrice().getAmount() : 0;
			}
			json.quotationItem.product.id = productId;
			for (productItemId in productItemIds) {
				json.quotationItem.product.items._data.append({
					values = [
						{ selected = true, product_item_id = productItemId }
					]
				});
			}
			var price = getPricing(json)
		}

		quotationItem.setPrice( price )
		update(quotationItem)
	}

	public function validateQuantity(
		required Quotation quotation,
		required QuotationItem quotationItem
	) {
		var productMinQuantity = quotationItem.getProduct().getMinQuantity()
		var productMaxQuantity = quotationItem.getProduct().getMaxQuantity()

		var productQuantity = 0
		if (productMinQuantity > 0 || productMaxQuantity > 0) {
			productQuantity = getProductQuantityByQuotation( quotation, quotationItem.getProduct() )
		}

		if ( productQuantity LT productMinQuantity || productQuantity GT productMaxQuantity ) {
			return false;
		}

		return true;
	}

	public function getProductQuantityByQuotation( Quotation quotation, Product product ) {
		var quotationItems = list( quotationId = quotation.getId() )
		var quantity = 0;
		for ( var item in quotationItems ) {
			if (!isNull(item.getArticle())) {
				continue;
			}
			if (item.getProduct().getId() == product.getId() ) {
				quantity += item.getQuantity()
			}
		}

		return quantity;
	}

	public function validateDiscounts(
		required numeric maxUserDiscount,
		required numeric quotationDiscount1,
		required numeric quotationDiscount2,
		required numeric itemDiscount1,
		required numeric itemDiscount2
	) {
		var factor =
			( 1 - arguments.quotationDiscount1 / 100 ) *
			( 1 - arguments.quotationDiscount2 / 100 ) *
			( 1 - itemDiscount1 / 100 ) *
			( 1 - itemDiscount2 / 100 );
		var totalDiscount = ( 1 - factor ) * 100;

		if ( totalDiscount GT arguments.maxUserDiscount ) {
			return false;
		}

		return true;
	}
}
