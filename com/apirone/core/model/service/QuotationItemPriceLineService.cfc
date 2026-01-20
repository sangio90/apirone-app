component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemPriceLineDAO";
	
	property name="cacheScope" type="String" default="QuotationItemPriceLine.bean";

	public com.apirone.core.model.bean.QuotationItemPriceLine function get( required String quotationItemPriceLineId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.quotationItemPriceLineId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationItemPriceLineId );

		cm.put(
			getCacheScope(),
			arguments.quotationItemPriceLineId,
			bean
		);

		return bean;

	}

	public Array function list(
		required String quotationItemPriceId,
	){
		
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "productItem.id" ] );
		
		var rows    = [];
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			var bean = get( record.quotation_item_price_line_id )
			rows.append( bean );
		} );

		return rows;
	}

	
	public Numeric function create( required com.apirone.core.model.bean.QuotationItemPriceLine quotationItemPriceLine ){
		var newId = getDao().insert( arguments.quotationItemPriceLine );

		return newId;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric quotationItemPriceId ){

		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemPriceId = arguments.quotationItemPriceId } );

		getDao().delete( arguments.quotationItemPriceId );

		return outcome;
	}
	

	/*
		PRIVATE METHODS
	*/

	private com.apirone.core.model.bean.QuotationItemPrice function build( required Numeric quotationItemPriceLineId ){
		var record = getDao().read( arguments.quotationItemPriceId );
		
		if ( record.recordCount ) {
			
			bean.setId( record.quotation_item_price_line_id );
			bean.setAmount( record.price );
			bean.setProductItemId( record.product_item_id );
			bean.setProductItemPriceId( record.product_item_price_id );

			return bean;
		}
		
		return NullValue();
	}

}
