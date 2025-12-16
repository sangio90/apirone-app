component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationPriceDAO";
	property name="QuotationService" inject="QuotationService";
	property name="quotationItemService" inject="QuotationItemService";
	property name="quotationPriceLineService" inject="QuotationPriceLineService";
	
	property name="cacheScope" type="String" default="QuotationPrice.bean";

	public com.apirone.core.model.bean.QuotationPrice function get( required String quotationPriceId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.quotationPriceId );

		if ( cache.status ) {
			return cache.data;
		}	

		var bean = build( arguments.quotationPriceId );

		cm.put(
			getCacheScope(),
			arguments.quotationPriceId,
			bean
		);

		return bean;

	}

	public com.apirone.core.model.bean.QuotationPrice function getByQuotationId( required String quotationId ){

		var rows = list( quotationId = arguments.quotationId );

		len( rows ) 
			? var bean = rows[1] 
			: var bean = null;

		return bean;

	}

	public com.apirone.core.model.bean.QuotationPrice function calculate( required String quotationId ){

		var totalItems = 0;
		var pricing = getByQuotationId( quotationId = arguments.quotationId );
		var quotation = getQuotationService().get( quotationId = arguments.quotationId );

		var items = getQuotationItemService().list( quotationId = arguments.quotationId );

		for( var item in items ) {
			totalItems = totalItems + item.getPrice().getTotal();
		}

		pricing.setTotalGoods( totalItems );
		pricing.setVatCode( quotation.getVatCode() );

		return pricing;

	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String quotationId,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationPrice.createdAt", dir = "desc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( quotationPriceId = record.quotation_price_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Struct function save( required com.apirone.core.model.bean.QuotationPrice quotationPrice ){

		var action = "";
		var rows = list( quotationId = arguments.quotationPrice.getQuotationId() );

		if( rows.len() ) {

			arguments.quotationPrice.setId( rows[1].getId() );

			var thisId = update( arguments.quotationPrice );
			action = "update";

		} else {
			var thisId = create( arguments.quotationPrice );
			action = "create";	
		}

		return { "action": action, "id": thisId };
	}

	public String function create( required QuotationPrice ){
		var newId = getDao().insert( arguments.QuotationPrice );

		for( var line in QuotationPrice.getLines() ) {
			line.setQuotationPriceId( newId );
			getQuotationPriceLineService().create( line );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationPrice quotationPrice ){

		var bean = getByQuotationId( arguments.quotationPrice.getQuotationId() );

		arguments.quotationPrice.setId( bean.getId() );

		getDao().update( arguments.quotationPrice );
		
		super.getCacheManager().remove( getCacheScope(), arguments.quotationPrice.getId() );

		return arguments.quotationPrice.getId();
	}

	private com.apirone.core.model.bean.QuotationPrice function build( required String quotationPriceId ){
		var record = getDao().read( arguments.quotationPriceId );
		
		if ( record.recordCount ) {
			
			var bean = super.bean( "QuotationPrice" );
			
			bean.setId( record.quotation_price_id );
			bean.setQuotationId( record.quotation_id );
			bean.setDiscount1( record.discount1 );
			bean.setDiscount2( record.discount2 );
			bean.setShippingCost( record.shipment_cost );
			bean.setCreatedAt( record.created_at );

			return bean;
		}
		
		return NullValue();
	}

}
