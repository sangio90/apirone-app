component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CountryDAO";
	property name="textService" inject="TextService";
	property name="cacheScope" type="String" default="Country.bean";

	public com.apirone.core.model.bean.Country function get( required String countryId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.countryId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.countryId );
		cm.put( getCacheScope(), arguments.countryId, bean );

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
		required Array orderBy  = [ { field = "country.code" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderby, "country" );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( countryId = record.country_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.Country country ){
		transaction {
			var newId = getDao().insert( arguments.country );


			for ( var text in arguments.country.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "country.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.country.getTexts() );
		}

		return newId;
	}

	public String function create( required com.apirone.core.model.bean.Country country ){
		transaction {
			var newId = getDao().insert( arguments.country );


			for ( var text in arguments.country.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "country.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.country.getTexts() );
		}

		return newId;
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.country_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String countryId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.countryId );

		outcome.setData( { countryId = arguments.countryId } );

		transaction {
			try {
				var result = getDao().delete( arguments.countryId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.countryId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteFinish" );
				outcome.setMessage( "Cannot delete country [#arguments.countryId#]" );
			}
		}

		return outcome;
	}

	/*
    	private method
	*/

	private com.apirone.core.model.bean.Country function build( required String countryId ){
		var record = getDao().read( arguments.countryId );

		if ( record.recordCount ) {
			var bean = super.bean( "Country" );
			bean.setId( record.country_id );
			bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );
			
			bean.setTexts( getTextService().list( countryId = record.country_id ) );
			
			return bean;
		}

		return NullValue();
	}

}
