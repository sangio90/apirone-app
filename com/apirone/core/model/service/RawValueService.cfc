component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="RawValueDAO";
	property name="textService" inject="TextService";
	property name="statusService" inject="statusService";

	property name="cacheScope" type="String" default="RawValue.bean";

	public com.apirone.core.model.bean.RawValue function get( required String rawValueId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.rawValueId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.rawValueId );

		cm.put( getCacheScope(), arguments.rawValueId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( rawValueId = record.raw_value_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.RawValue rawValue ){
		transaction {
			var newId = getDao().insert( arguments.rawValue );

			for ( var text in arguments.rawValue.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "rawValue.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.rawValue.getTexts() );
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.rawValue rawValue ){
		var id = arguments.rawValue.getId();

		getDao().update( arguments.rawValue );

		for ( var text in arguments.rawValue.getTexts() ) {
			var entity = super.bean( "Entity" )

			entity.setKey( "rawValue.id" );
			entity.setValue( id );

			text.setEntity( entity );

			if ( Len( text.getId() ) ) {
				getTextService().update( text );
			} else {
				getTextService().create( text );
			}
		}

		super.getCacheManager().remove( getCacheScope(), id );

		return id;
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.raw_value_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric rawValueId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.rawValueId );

		outcome.setData( { rawValueId = arguments.rawValueId } );

		transaction {
			try {
				var result = getDao().delete( arguments.rawValueId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.rawValueId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteRawValue" );
				outcome.setMessage( "Cannot delete rawValue [#arguments.rawValueId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.rawValue function build( required String rawValueId ){
		var record = getDao().read( arguments.rawValueId );

		if ( record.recordCount ) {
			var bean = super.bean( "rawValue" );

			bean.setId( record.raw_value_id );
			bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );

			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setTexts( getTextService().list( rawValueId = record.raw_value_id ) );

			return bean;
		}

		return NullValue();
	}

}
