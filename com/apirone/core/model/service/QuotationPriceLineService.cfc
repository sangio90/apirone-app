component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationPriceLineDAO";
	
	property name="cacheScope" type="String" default="QuotationPriceLine.bean";

	public com.apirone.core.model.bean.QuotationPriceLine function get( required String quotationPriceLineId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.quotationPriceLineId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationPriceLineId );

		cm.put(
			getCacheScope(),
			arguments.quotationPriceLineId,
			bean
		);

		return bean;

	}

	public Array function list(
		required String quotationPriceId,
	){
		
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "quotationPriceLine.id" ] );
		
		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			var bean = get( record.quotation_price_line_id )
			rows.append( bean );
		} );

		return rows;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric quotationPriceLineId ){

		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationPriceLineId = arguments.quotationPriceLineId } );
		getDao().delete( arguments.quotationPriceLineId );

		return outcome;
	}
	
	public Numeric function create( required QuotationPriceLine ){
		var newId = getDao().insert( arguments.QuotationPriceLine );

		return newId;
	}

	private com.apirone.core.model.bean.QuotationItemPrice function build( required Numeric quotationPriceLineId ){
		var record = getDao().read( arguments.quotationItemPriceId );
		
		if ( record.recordCount ) {
			var bean = super.bean( "QuotationPriceLine" );

			bean.setId( record.quotation_price_line_id );
			bean.setAmount( record.price );
			bean.setQuotationPriceId( record.quotation_price_id );

			return bean;
		}
		
		return NullValue();
	}

}
