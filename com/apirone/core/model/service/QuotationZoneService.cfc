component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationZoneDAO";
	property name="QuotationService" inject="QuotationService";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="QuotationItemFruitService" inject="QuotationItemFruitService";
	property name="QuotationItemPriceService" inject="QuotationItemPriceService";
	property name="QuotationItemProductItemService" inject="QuotationItemProductItemService";
	property name="QuotationItemSignageRowService" inject="QuotationItemSignageRowService";
	property name="FileService" inject="FileService";
	property name="QuotationZoneService" inject="QuotationZoneService";
	property name="cacheScope" type="String" default="QuotationZone.bean";

	public com.apirone.core.model.bean.QuotationZone function get( required String zoneId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.zoneId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.zoneId );
		cm.put( getCacheScope(), arguments.zoneId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotation.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( zoneId = record.quotation_zone_id ) );
		} );
		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String zoneId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.zoneId );

		outcome.setData( { zoneId = arguments.zoneId } );
		
		var cm = getCacheManager();
		
		transaction {
			try {
				getDao().delete( arguments.zoneId );
				cm.remove( getCacheScope(), arguments.zoneId );
			} catch ( any error ) {
				rethrow
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationZone" );
				outcome.setMessage( "Cannot delete zone [#arguments.zoneId#]" );
			}
		}
		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationZone zone ){
		var newId = getDao().insert( arguments.zone );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationZone zone ){
		getDao().update( arguments.zone );
		var children = list( originId = arguments.zone.getId() )
		super.getCacheManager().remove( getCacheScope(), arguments.zone.getId() );
		for (var child in children) {
			super.getCacheManager().remove( getCacheScope(), child.getId() );
		}

		return arguments.zone.getId();
	}

	public function duplicateZoneItems( required String duplicatedZoneId, required String newZoneId ) {
		var items = getQuotationItemService().list( quotationZoneId = arguments.duplicatedZoneId );
		var newZone = getQuotationZoneService().get( arguments.newZoneId )

		for (var quotationItem in items) {
			var duplicatedItem = Duplicate( quotationItem );
			duplicatedItem.setQuotationZone( newZone )
			var newItemId = getQuotationItemService().create( duplicatedItem );
			var newItem = getQuotationItemService().get( newItemId );

			//file
			var quotationItemFile = getFileService().search( quotationItemId = quotationItem.getId() ).getData();
			if ( Len(quotationItemFile) > 0 ) {
				var duplicatedFile = Duplicate( quotationItemFile[1] );
				getFileService().duplicate( duplicatedFile.getId(), newItem );
			}

			//quotation Item Product items
			var quotationItemProductItems = getQuotationItemProductItemService().list( quotationItemId = quotationItem.getId() );
			for ( var quotationItemProductItem in quotationItemProductItems ) {
				quotationItemProductItem.setId('')
				quotationItemProductItem.setQuotationItemId( newItemId )
				getQuotationItemProductItemService().create( quotationItemProductItem )
			}

			//quotation item signage rows
			var quotationItemSignageRows = getQuotationItemSignageRowService().list( quotationItemId = quotationItem.getId() );
			for ( var quotationItemSignageRow in quotationItemSignageRows ) {
				quotationItemSignageRow.setId('')
				quotationItemSignageRow.setQuotationItemId( newItemId )
				getQuotationItemSignageRowService().create( quotationItemSignageRow )
			}
		}

		return newZone
	}

	private com.apirone.core.model.bean.QuotationZone function build( required String zoneId ){
		var record = getDao().read( arguments.zoneId );
		if ( record.recordCount ) {

			var bean = super.bean( "QuotationZone" );

			bean.setId( record.quotation_zone_id );
			bean.setName( record.quotation_zone );
			bean.setQuantity( record.quantity );
			bean.setQuotation( getQuotationService().get( record.quotation_id ) );

			bean.setOrigin(
				IsNull( record.origin_id ) ? NullValue() : getQuotationZoneService().get( record.origin_id )
			);

			return bean;
		}
		return NullValue();
	}

}
