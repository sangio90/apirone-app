component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationPriceDAO";
	property name="quotationItemService" inject="QuotationItemService";
	property name="quotationPriceLineService" inject="QuotationPriceLineService";
	
	property name="cacheScope" type="String" default="QuotationPrice.bean";

	public com.apirone.core.model.bean.QuotationPrice function get( required String quotationItemId ){
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

	public com.apirone.core.model.bean.QuotationPrice function calculate( required String quotationId ){

		// inietto i dati

		// fai il calcolo

		return bean;

	}

	public String function create( required QuotationPrice ){
		var newId = getDao().insert( arguments.QuotationPrice );

		for( var line in QuotationPrice.getLines() ) {
			line.setQuotationPriceId( newId );
			getQuotationPriceLineService().create( line );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationPrice QuotationPrice ){
		getDao().update( arguments.Quotation );
		super.getCacheManager().remove( getCacheScope(), arguments.quotation.getId() );

		return arguments.quotation.getId();
	}

	private com.apirone.core.model.bean.QuotationPrice function build( required String quotationItemId ){
		var record = getDao().read( arguments.quotationItemId );
		
		if ( record.recordCount ) {
			
			var bean = super.bean( "QuotationPrice" );
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
