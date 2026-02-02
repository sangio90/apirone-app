component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemFruitPositionDAO";
	property name="cacheScope" type="String" default="QuotationItemFruitPosition.bean";

	public com.apirone.core.model.bean.QuotationItemFruit function get( required Numeric quotationItemFruitPositionId ){
		var cm    = getCacheManager();
		var cache = cm.get( getCacheScope(), arguments.quotationItemFruitPositionId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationItemFruitId );

		cm.put(
			getCacheScope(),
			arguments.quotationItemFruitId,
			bean
		);

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationItemFruit.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.quotation_item_fruit_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric quotationItemFruitPositionId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemFruitPositionId = arguments.quotationItemFruitPositionId } );
		getDao().delete( arguments.quotationItemFruitPositionId );
		
		transaction {
			try {
				var cm = getCacheManager();
				getDao().delete( arguments.quotationItemFruitPositionId );
				cm.remove( getCacheScope(), arguments.quotationItemFruitPositionId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteQuotationItemFruitPosition" );
				outcome.setMessage( "Cannot delete quotation item fruit position [#arguments.quotationItemFruitPositionId#]" );
			}
		}

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByQuotationItemFruitId( required Numeric quotationItemFruitId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemFruitId = arguments.quotationItemFruitId } );
		getDao().deleteByQuotationItemFruitId( arguments.quotationItemFruitId );
		
		transaction {
			try {
				var cm = getCacheManager();
				getDao().deleteByQuotationItemFruitId( arguments.quotationItemFruitId );
				cm.remove( getCacheScope(), arguments.quotationItemFruitId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteQuotationItemFruitPosition" );
				outcome.setMessage( "Cannot delete quotation item fruit position by fruitId: [#arguments.quotationItemFruitId#]" );
			}
		}

		return outcome;
	}

	public Numeric function create( required quotationItemFruitId, required String position ){
		var newId = getDao().insert( argumentCollection = arguments );

		return newId;
	}

}
