component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PriceTypeDAO";
	property name="statusService" inject="StatusService";

	property name="cacheScope" type="String" default="PriceType.bean";

	public com.apirone.core.model.bean.PriceType function get( required String priceTypeId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.priceTypeId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.priceTypeId  );
		cm.put( getCacheScope(), arguments.priceTypeId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "priceType.id", desc = "asc" } ]
	){
		
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.price_type_id ) );
		} );

		result.setData( rows );
		result.setTotal( Val( records.total ) );
		result.setCount( Val( records.recordcount ) );
		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String priceTypeId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.priceTypeId, false );

		outcome.setData( { priceTypeId = arguments.priceTypeId } );

		transaction {
			try {
				getDao().delete( arguments.priceTypeId );
				super.logEvent(
					event   = "price.deleted",
					message = "Price type [#arguments.priceTypeId#] deleted.",
					payload = { "id" = arguments.priceTypeId }
				);
				super.getCacheManager().remove( getCacheScope(), arguments.priceTypeId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeletePriceType" );
				outcome.setMessage( "Cannot delete price type [#arguments.priceTypeId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.PriceType price ){

		var id = getDao().insert( arguments.price );

		return id;
	}


	public String function update( required com.apirone.core.model.bean.price price ){
		getDao().update( arguments.price );

		super.getCacheManager().remove( getCacheScope(), price.getId() );

		return arguments.price.getId();
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.PriceType function build( required String priceTypeId ){
		var record = getDao().read( arguments.priceTypeId );

		if ( record.recordCount ) {
			var bean = super.bean( "PriceType" );

			bean.setId( record.price_type_id );

			bean.setName( record.price_type );
			bean.setCreatedAt( record.created_at );
			
			bean.setStatus( getStatusService().get( record.status_id ) );

			return bean;
		}

		return NullValue();
	}

}
