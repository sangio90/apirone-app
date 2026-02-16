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
		required Array orderBy  = [ { field = "quotationItemPriceLine.id", desc = "asc" } ]
	){
		
		arguments[ "orderby" ] = super.createOrderBy( arguments.orderBy );
		
		var rows    = [];
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			var bean = get( record.quotation_item_price_line_id )
			rows.append( bean );
		} );

		return rows;
	}

	
	public Numeric function create( required com.apirone.core.model.bean.QuotationItemPriceLine quotationItemPriceLine ){
		cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceLineService: create line, productItemId: #quotationItemPriceLine.getQuotationItemPriceId()#, price: #quotationItemPriceLine.getAmount()#");

		var newId = getDao().insert( arguments.quotationItemPriceLine );

		return newId;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric quotationItemPriceLineId ){

		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemPriceLineId = arguments.quotationItemPriceLineId } );

		getDao().delete( arguments.quotationItemPriceLineId );

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByQuotationItemPriceId( required Numeric quotationItemPriceId ){

		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemPriceId = arguments.quotationItemPriceId } );

		getDao().deleteByQuotationItemPriceId( arguments.quotationItemPriceId );

		return outcome;
	}
	

	/*
		PRIVATE METHODS
	*/

	private com.apirone.core.model.bean.QuotationItemPriceLine function build( required Numeric quotationItemPriceLineId ){
		var record = getDao().read( arguments.quotationItemPriceLineId );
		
		if ( record.recordCount ) {

			var bean = super.bean( "QuotationItemPriceLine" );
			
			bean.setId( record.quotation_item_price_line_id );
			bean.setAmount( record.amount );
			bean.setCost( record.cost );
			//bean.setProductItemId( record.product_item_id );
			//bean.setProductItemPriceId( record.product_item_price_id );
			bean.setQuotationItemPriceId( record.quotation_item_price_id );
			bean.setName( record.name ); //TODO: rename this field to quotation_item_price_line
			bean.setCreatedAt( record.created_at ); 

			return bean;
		}
		
		return NullValue();
	}

}
