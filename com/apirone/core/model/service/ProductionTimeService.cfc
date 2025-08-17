component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="com.apirone.core.model.dao.ProductionTimeDAO";
	property name="statusService" inject="com.apirone.core.model.service.StatusService";

	property name="cacheScope" type="String" default="productionTime.bean";

	public com.apirone.core.model.bean.ProductionTime function get( required String productionTimeId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.productionTimeId );

		if ( cache.status ) {
			return cache.data;
		}

		var product = build( arguments.productionTimeId );
		cm.put(
			getCacheScope(),
			arguments.productionTimeId,
			product
		);

		return product;
	}

	public Boolean function codeExists( required String code, String excludeId = "" ){
		var products = search( code = arguments.code ).getData();

		return !IsNull( products[ 1 ] ) AND products[ 1 ].getId() NEQ arguments.excludeId
	}

	public com.apirone.core.model.bean.Result function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments );
	}

	public com.apirone.core.model.bean.Result function search(
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( productionTimeId = record.production_time_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.ProductionTime productionTime ){
		var newId = getDao().insert( arguments.productionTime );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.ProductionTime productionTime ){
		getDao().update( arguments.productionTime );

		var id = arguments.productionTime.getId();

		super.getCacheManager().remove( getCacheScope(), id );

		return id;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productionTimeId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.productionTimeId );

		outcome.setData( { productionTimeId = arguments.productionTimeId } );

		transaction {
			try {
				var result = getDao().delete( arguments.productionTimeId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.productionTimeId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProductionTime" );
				outcome.setMessage( "Cannot delete productionTime [#arguments.productionTimeId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.ProductionTime function build( required String productionTimeId ){
		var record = getDao().read( arguments.productionTimeId );

		if ( record.recordCount ) {
			var bean = super.bean( "ProductionTime" );

			bean.setId( record.production_time_id );
			bean.setName( record.production_time );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setCreatedAt( record.created_at );

			return bean;
		}

		return NullValue();
	}

}
