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
	property name="LookupService" inject="LookupService";

	property name="cacheScope" type="String" default="QuotationItem.bean";

	public com.apirone.core.model.bean.QuotationItem function get( required String quotationItemId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.quotationItemId );

		if ( cache.status ) {
			return cache.data;
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

	public com.apirone.core.model.bean.Result function search(
		String str,
		String mode,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotation.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			var quotationItem = get( quotationItemId = record.quotation_item_id );
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

			<!---- 
				TODO: per Umberto: possiamo togliere queste query
			--->
			```
			<cfquery name="total" datasource="apirone">
				SELECT SUM(amount) AS total
				FROM quotation_items
					INNER JOIN quotation_item_prices ON quotation_items.quotation_item_id = quotation_item_prices.quotation_item_id
				WHERE 1=1
					AND quotation_items.quotation_item_id = '#record.quotation_item_id#'
			</cfquery>

			<cfquery name="total" datasource="apirone">
				SELECT SUM(amount) AS total
				FROM quotation_items
					INNER JOIN quotation_item_prices ON quotation_items.quotation_item_id = quotation_item_prices.quotation_item_id
				WHERE 1=1
					AND quotation_items.quotation_item_id = '#record.quotation_item_id#'
			</cfquery>
			```

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

			if( Len( record.quotation_zone_position_id ) ) {
				bean.setPosition( getQuotationZonePositionService().get( record.quotation_zone_position_id ) );
			}
		
			return bean;
		}

		return NullValue();
	}

	public function getAltreRigheByQuotationLineIdAndFinishId( 
		required String quotationItemId, 
		required String quotationId,
		required String finishId,
		required String lineId
	){
		if ( IsNull( quotationId ) ) {
			return [];
		}
		return getDao().getAltreRigheByQuotationLineIdAndFinishId(argumentCollection = arguments);
	}

}
