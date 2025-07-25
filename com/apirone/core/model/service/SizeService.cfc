component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="SizeDAO";
	property name="statusService" inject="StatusService";
	property name="textService" inject="TextService";
	property name="lookupService" inject="lookupService";

	property name="cacheScope" type="String" default="Size.bean";

	public com.apirone.core.model.bean.Size function get( required String sizeId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.sizeId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.sizeId );
		cm.put( getCacheScope(), arguments.sizeId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String lineId,
		String str,
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( sizeId = record.size_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.Size size ){
		var newId = getDao().insert( arguments.size );

		transaction {
			for ( var text in arguments.size.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "size.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.size.getTexts() );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.Size size ){

        //dump(getDao() );
        //abort;

		getDao().update( arguments.size );

		var id = arguments.size.getId();

		transaction {
			for ( var text in arguments.size.getTexts() ) {
				var entity = super.bean( "Entity" )

				entity.setKey( "size.id" );
				entity.setValue( id );

				text.setEntity( entity );

				if ( Len( text.getId() ) ) {
					getTextService().update( text );
				} else {
					getTextService().create( text );
				}
			}
		}

		super.getCacheManager().remove( getCacheScope(), arguments.size.getId() );

		return arguments.size.getId();
	}


	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.size_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}


	public com.apirone.core.model.bean.Outcome function delete( required String sizeId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.sizeId );

		outcome.setData( { sizeId = arguments.sizeId } );

		transaction {
			try {
				var result = getDao().delete( arguments.sizeId );
				outcome.setData( { "deletedCount" = result } )

				super.getCacheManager().remove( getCacheSciope(), arguments.sizeId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteSize" );
				outcome.setMessage( "Cannot delete size [#arguments.sizeId#]" );
			}
		}

		return outcome;
	}



	/*
    	private method
	*/

	private com.apirone.core.model.bean.Size function build( required String sizeId ){
		var record = getDao().read( arguments.sizeId );

		if ( record.recordCount ) {
			var bean = super.bean( "Size" );

			bean.setId( record.size_id );
			bean.setName( record.size );
			bean.setCode( record.code );
			bean.setFruitsCount( record.fruits_count );

			bean.setType( getLookupService().get( "sizeType", record.size_type_id ) );
			bean.setCategories( getCategoriesBeanByIds( record.categories ) );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setTexts( getTextService().list( sizeId = record.size_id ) );

			bean.setCreatedAt( record.created_at );

			return bean;
		}

		return NullValue();
	}

}
