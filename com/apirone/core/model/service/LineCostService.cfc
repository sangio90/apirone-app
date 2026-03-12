component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="LineCostDAO";
	property name="lineService" inject="LineService";
	property name="finishService" inject="FinishService";
	property name="productCategoryService" inject="ProductCategoryService";
	property name="productItemService" inject="ProductItemService";
	property name="cacheScope" type="String" default="LineCost.bean";

	public com.apirone.core.model.bean.LineCost function get( required Numeric lineCostId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.lineCostId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.lineCostId );
		cm.put( getCacheScope(), arguments.lineCostId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		Numeric categoryId,
		String lineId,
		String finishId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "linecost.line_code", desc = "asc" }, { field = "linecost.finish_code", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( lineCostId = record.line_cost_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.LineCost lineCost ){
		transaction {
			var newId = getDao().insert( arguments.lineCost );
		}

		super.logEvent(
			event   = "lineCost.created",
			message = "LineCost [#newId#] created",
			payload = { "id" = newId }
		);

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.LineCost lineCost ){

		getDao().update( arguments.lineCost );

		var id = arguments.lineCost.getId();

		super.logEvent(
			event   = "lineCost.updated",
			message = "LineCost [#arguments.lineCost.getId()#] updated",
			payload = { "id" = arguments.lineCost.getId() }
		);

		super.getCacheManager().remove( getCacheScope(), arguments.lineCost.getId() );

		return arguments.lineCost.getId();
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric lineCostId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.lineCostId );

		outcome.setData( { lineCostId = arguments.lineCostId } );

		transaction {
			try {
				var result = getDao().delete( arguments.lineCostId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.lineCostId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteLine" );
				outcome.setMessage( "Cannot delete lineCost [#arguments.lineCostId#]" );
			}
		}

		super.logEvent(
			event   = "lineCost.deleted",
			message = "LineCost [#arguments.lineCostId#] deleted",
			payload = { "id" = arguments.lineCostId }
		);

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.LineCost function build( required Numeric lineCostId ){
		var record = getDao().read( arguments.lineCostId );

		if ( record.recordCount ) {
			var bean = super.bean( "LineCost" );

			bean.setId( record.line_cost_id );
			bean.setLine( getLineService().get( record.line_id ) );
			bean.setFinish( getFinishService().get( record.finish_id ) );
			bean.setCategory( getProductCategoryService().get( record.product_category_id ) );
			bean.setCost( record.cost );
			return bean;
		}

		return NullValue();
	}

}
