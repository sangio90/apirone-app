component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemPriceDAO";
	property name="quotationItemPriceLineService" inject="QuotationItemPriceLineService";
	
	property name="cacheScope" type="String" default="QuotationItemPrice.bean";

	public com.apirone.core.model.bean.QuotationItemPrice function get( required String quotationItemPriceId ){
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
		String quotationitemId,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotation.id" } ]
	){
		
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "productItem.id" ] );
		
		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			var bean = get( record.quotation_item_price_id )
			rows.append( bean );
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

		return outcome;
	}

	public String function create( required quotationItemPrice ){
		var newId = getDao().insert( arguments.quotationItemPrice );

		for( var line in quotationItemPrice.getLines() ) {
			line.setQuotationItemPriceId( newId );
			getQuotationItemPriceLineService().create( line );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.quotationItemPrice quotationItemPrice ){
		getDao().update( arguments.quotationItem );
		super.getCacheManager().remove( getCacheScope(), arguments.quotationItem.getId() );

		return arguments.quotationItem.getId();
	}

	private com.apirone.core.model.bean.QuotationItemPrice function build( required String quotationItemPriceId ){
		var record = getDao().read( arguments.quotationItemPriceId );
		
		if ( record.recordCount ) {
			
			var bean = super.bean( "QuotationItemPrice" );
			var method = super.bean( "PriceMethod" );
			
			bean.setDiscount1( record.discount1 );
			bean.setDiscount2( record.discount2 );
			bean.setAmount( record.price );

			bean.setId( record.quotation_item_price_id );

			return bean;
		}
		
		return NullValue();
	}

}
