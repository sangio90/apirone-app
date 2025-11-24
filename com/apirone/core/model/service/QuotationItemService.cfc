component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemDAO";
	property name="quotationItemFruitService" inject="QuotationItemFruitService";
	property name="QuotationService" inject="QuotationService";
	property name="QuotationZoneService" inject="QuotationZoneService";
	property name="QuotationItemProductItemService" inject="QuotationItemProductItemService";
	property name="ProductService" inject="ProductService";
	property name="SignageConfigItemService" inject="SignageConfigItemService";
	property name="FileService" inject="FileService";
	property name="QuotationItemSignageRowService" inject="QuotationItemSignageRowService";
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
		String mode = null,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotation.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );
		var rows               = [];
		var result             = super.getResult();
		var records            = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			var quotationItem = get( quotationItemId = record.quotation_item_id )
			if ( mode == null ) {
				rows.add( quotationItem )
			} else {
				if ( mode == 'placche') {
					if (IsInstanceOf( quotationItem, 'com.apirone.core.model.bean.QuotationItemPlate' )) {
						rows.add( quotationItem );
					}
				} else {
					if (!IsInstanceOf( quotationItem, 'com.apirone.core.model.bean.QuotationItemPlate' )) {
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
		var obj     = get( arguments.quotationItemId );

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

	public String function create( required quotationItem ){
		var newId = getDao().insert( arguments.quotationItem );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItem quotationItem ){
		getDao().update( arguments.quotationItem );
		super.getCacheManager().remove( getCacheScope(), arguments.quotationItem.getId() );

		return arguments.quotationItem.getId();
	}

	private com.apirone.core.model.bean.QuotationItem function build( required String quotationItemId ){
		var record = getDao().read( arguments.quotationItemId );
		var fruits = getQuotationItemFruitService().list( quotationItemId = arguments.quotationItemId )
		if ( record.recordCount ) {
			if (fruits.len() > 0) {
				var bean = super.bean( "QuotationItemPlate" );
				bean.setFruits(fruits)
			} else {
				if (Len(record.signage_config_item_id)) {
					var bean = super.bean( "QuotationItemSignage" );
				} else {
					var bean = super.bean( "QuotationItem" );
				}
			}

			bean.setId( record.quotation_item_id );
			bean.setPrice( record.price );
			bean.setQuantity( record.quantity );
			bean.setQuotation( getQuotationService().get( record.quotation_id ) );
			if (Len(record.product_id)) {
				bean.setProduct( getProductService().get( record.product_id ) );
			}
			bean.setQuotationZone(
				IsNull( record.quotation_zone_id ) ? NullValue() : getQuotationZoneService().get(
					record.quotation_zone_id
				)
			);

			if (Len(record.signage_config_item_id)) {
				bean.setSignageConfigItem( getSignageConfigItemService().get( record.signage_config_item_id ) );
				if (record.char_count) {
					bean.getSignageConfigItem().setCharCount(record.char_count);
				}
				if (record.height_in_pixel) {
					bean.getSignageConfigItem().setHeightInPixel(record.height_in_pixel);
				}
				if (record.row_count) {
					bean.getSignageConfigItem().setRowCount(record.row_count);
				}
				var signageRows = getQuotationItemSignageRowService().list( quotationItemId = quotationItemId );
				bean.setSignageRows( signageRows );
			}

			var images = getFileService().list( quotationItemId = record.quotation_item_id );
			if (Len(images)) {
				bean.setImage(images[1]);
			}

			var items = getQuotationItemProductItemService().list( quotationItemId = quotationItemId );
			if (Len(items)) {
				bean.setItems(items);
			}

			bean.setNotes( record.notes );

			return bean;
		}
		return NullValue();
	}

}
