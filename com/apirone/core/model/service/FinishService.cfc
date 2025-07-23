component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.FinishDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="ProductCategoryService" type="com.apirone.core.model.service.ProductCategoryService";
	property name="textService" type="com.apirone.core.model.service.TextService";
	property name="cacheScope" type="String" default="Finish.bean";

	public com.apirone.core.model.bean.Finish function get( required String finishId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.finishId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.finishId );
		cm.put( getCacheScope(), arguments.finishId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String lineId,
		required Array orderBy = [ { field = "finish.code" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderby, "finish" );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( finishId = record.finish_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.Finish finish ){
		transaction {
			var newId = getDao().insert( arguments.finish );

			for ( var text in arguments.finish.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "finish.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.finish.getTexts() );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.Finish finish ){
		getDao().update( arguments.finish );

		super.getCacheManager().remove( getCacheScope(), arguments.finish.getId() );

		return arguments.finish.getId();
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.finish_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String finishId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.finishId );

		outcome.setData( { finishId = arguments.finishId } );

		transaction {
			try {
				var result = getDao().delete( arguments.finishId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.finishId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteFinish" );
				outcome.setMessage( "Cannot delete finish [#arguments.finishId#]" );
			}
		}

		return outcome;
	}

	/*
    	private method
	*/

	private com.apirone.core.model.bean.Finish function build( required String finishId ){
		var record = getDao().read( arguments.finishId );

		if ( record.recordCount ) {
			var bean = super.bean( "Finish" );

			bean.setId( record.finish_id );
			bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );

			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setTexts( getTextService().list( finishId = record.finish_id ) );

			var categories = getCategoriesBeanByIds( record.categories )

			bean.setCategories( categories );

			return bean;
		}

		return NullValue();
	}

}
