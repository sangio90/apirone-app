component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemProductDAO";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="ProductService" inject="ProductService";
	property name="QuotationItemProductService" inject="QuotationItemProductService";

	public com.apirone.core.model.bean.QuotationItemProduct function get( required String productId ){
		return build( arguments.productId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationItemProduct.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();

		// // Il find() restituisce già le FK: si possono costruire i bean direttamente
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( buildFromFindRow( record ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.productId );

		outcome.setData( { productId = arguments.productId } );

		transaction {
			try {
				getDao().delete( arguments.productId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItemProduct" );
				outcome.setMessage( "Cannot delete product [#arguments.productId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemProduct product ){
		var newId = getDao().insert( arguments.product );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemProduct product ){
		getDao().update( arguments.product );

		return arguments.product.getId();
	}

	/**
	 * Costruisce un bean QuotationItemProduct a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.QuotationItemProduct function build( required String productId ){
		var record = getDao().read( arguments.productId );
		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}
		return NullValue();
	}

	/**
	 * Costruisce un bean QuotationItemProduct a partire da una riga della query.
	 * Le sub-entity (QuotationItem, Product, origin) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.QuotationItemProduct function buildFromFindRow( required any record ){
		var bean = super.bean( "QuotationItemProduct" );

		// Campi diretti dal record
		bean.setId( record.quotation_item_product_id );

		// Entity collegate (caricate singolarmente)
		bean.setQuotationItem( getQuotationItemService().get( record.quotation_item_id ) );
		bean.setProduct( getProductService().get( record.product_id ) );

		bean.setOrigin(
			IsNull( record.origin_id ) ? NullValue() : getQuotationItemProductService().get( record.origin_id )
		);

		return bean;
	}

}
