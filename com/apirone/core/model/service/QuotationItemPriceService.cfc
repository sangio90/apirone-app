component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemPriceDAO";
	property name="quotationItemPriceLineService" inject="QuotationItemPriceLineService";
	
	property name="cacheScope" type="String" default="QuotationItemPrice.bean";

	public com.apirone.core.model.bean.QuotationItemPrice function get( required Numeric quotationItemPriceId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.quotationItemPriceId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationItemPriceId );

		cm.put(
			getCacheScope(),
			arguments.quotationItemPriceId,
			bean
		);

		return bean;

	}

	public com.apirone.core.model.bean.QuotationItemPrice function getByQuotationItemId( required String quotationItemId ){

		var rows = list( quotationItemId = arguments.quotationItemId );

		if( rows.len() EQ 0 ){
			return NullValue();
		}

		return rows[1];

	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String quotationitemId,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationItemPrice.id" } ]
	){
		
		arguments[ "orderby" ] = super.createOrderBy( arguments.orderBy );
		
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

	public com.apirone.core.model.bean.Outcome function delete( required String quotationItemPriceId ){

		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemPriceId = arguments.quotationItemPriceId } );

		getDao().delete( arguments.quotationItemPriceId );

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemPrice quotationItemPrice ){
		var newId = getDao().insert( arguments.quotationItemPrice );

		cffile( action="append", file="#ExpandPath('/debug.log')#", output="quotationItemPriceService: newId:#newId#, lines: #quotationItemPrice.getLines().len()#");

		if( !IsNull( quotationItemPrice.getLines() ) ) {

			cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceService: if !null before loop on lines newId:#newId#, lines: #quotationItemPrice.getLines().len()#");
			
			for( var line in quotationItemPrice.getLines() ) {
				cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceService: line newId:#newId#, lines: #quotationItemPrice.getLines().len()#");

				line.setQuotationItemPriceId( newId );
				getQuotationItemPriceLineService().create( line );
			}
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemPrice quotationItemPrice ){
		getDao().update( arguments.quotationItemPrice );
		super.getCacheManager().remove( getCacheScope(), arguments.quotationItemPrice.getId() );

		//cancello le righe esistenti
		getQuotationItemPriceLineService().deleteByQuotationItemPriceId( quotationItemPriceId = arguments.quotationItemPrice.getId() )

		if( !IsNull( quotationItemPrice.getLines() ) ) {

			cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceService: if !null before loop on lines newId:#quotationItemPrice.getId()#, lines: #quotationItemPrice.getLines().len()#");
			
			for( var line in quotationItemPrice.getLines() ) {
				cffile( action="append", file="#ExpandPath('/debug.log')#", output="QuotationItemPriceService: line newId:#quotationItemPrice.getId()#, lines: #quotationItemPrice.getLines().len()#");

				line.setQuotationItemPriceId( quotationItemPrice.getId() );
				getQuotationItemPriceLineService().create( line );
			}
		}

		return arguments.quotationItemPrice.getId();
	}

	private com.apirone.core.model.bean.QuotationItemPrice function build( required String quotationItemPriceId ){
		var record = getDao().read( arguments.quotationItemPriceId );
		
		if ( record.recordCount ) {
			
			var bean = super.bean( "QuotationItemPrice" );
			var method = super.bean( "PriceMethod" );
			
			bean.setDiscount1( record.discount1 );
			bean.setDiscount2( record.discount2 );
			bean.setAmount( record.amount );
			//bean.setFlatDiscount( record.flat_discount );
			bean.setMethod( method.setId( record.price_method_id ) );

			bean.setId( record.quotation_item_price_id );
			bean.setLines( getQuotationItemPriceLineService().list( quotationItemPriceId = arguments.quotationItemPriceId ) );

			return bean;
		}
		
		return NullValue();
	}

}
