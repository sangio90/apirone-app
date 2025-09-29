component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PriceDAO";
	property name="statusService" inject="StatusService";
	property name="productService" inject="ProductService";
	property name="productItemService" inject="ProductItemService";
	property name="priceTypeService" inject="PriceTypeService";

	property name="cacheScope" type="String" default="Price.bean";

	public com.apirone.core.model.bean.Price function get( required String priceId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.priceId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.priceId  );
		cm.put( getCacheScope(), arguments.priceId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String productId,
		Numeric productItemId,
		String statusId,
	){
		
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.price_id, false ) );
		} );

		result.setData( rows );
		result.setTotal( Val( records.total ) );
		result.setCount( Val( records.recordcount ) );
		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String priceId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.priceId, false );

		outcome.setData( { priceId = arguments.priceId } );

		transaction {
			try {
				getDao().delete( arguments.priceId );
				super.logEvent(
					event   = "price.deleted",
					message = "Price [#arguments.priceId#] deleted.",
					payload = { "id" = arguments.priceId }
				);
				super.getCacheManager().remove( getCacheScope(), arguments.priceId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeletePrice" );
				outcome.setMessage( "Cannot delete price [#arguments.priceId#]" );
			}
		}

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByParams(
		required  com.apirone.core.model.bean.Price price
	){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.price.getId() );

		outcome.setData( { price = arguments.price } );

		transaction {
			try {
				getDao().deleteByParams( arguments.price );

				super.getCacheManager().remove( getCacheScope(), obj.getId() );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeletePrice" );
				outcome.setMessage( "Cannot delete pricd [#obj.getId()#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.Price price ){

		var id = getDao().insert( arguments.price );

		return id;
	}

	public String function update( required com.apirone.core.model.bean.Price price ){
		getDao().update( arguments.price );

		super.getCacheManager().remove( getCacheScope(), price.getId() );

		return arguments.price.getId();
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.Price function build( required String priceId ){
		var record = getDao().read( arguments.priceId );

		if ( record.recordCount ) {
			var bean = super.bean( "Price" );

			bean.setId( record.price_id );

			bean.setAmount( record.amount );
			bean.setCreatedAt( record.created_at );
			bean.setMethod( getLookupService().get( "priceMethod", record.method_id ) );
			bean.setType( getPriceTypeService().get( record.price_type_id ) );

			bean.setStatus( getStatusService().get( record.status_id ) );

			return bean;
		}

		return NullValue();
	}

}
