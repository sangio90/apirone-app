component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PictogramDAO";
	//property name="textService" inject="TextService";
	property name="lookupService" inject="LookupService";
	property name="FileService" inject="FileService";

	property name="cacheScope" type="String" default="Pictogram.bean";

	public com.apirone.core.model.bean.Pictogram function get( required String pictogramId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.pictogramId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.pictogramId );
		cm.put( getCacheScope(), arguments.pictogramId, bean );

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
		required Array orderBy  = [ { field = "pictogram.id" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderby );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( pictogramId = record.pictogram_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Boolean function fontFamilyExists( required String code, required Numeric fontFamilyId, String excludedId = "" ){
		var record = getDao().readByCodeAndFontFamily( code = arguments.code, fontFamilyId = arguments.fontFamilyId );

		if (
			record.recordCount
			&& record.pictogram_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public String function create( required com.apirone.core.model.bean.Pictogram pictogram ){
		var newId = getDao().insert( arguments.pictogram );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.Pictogram pictogram ){
		getDao().update( arguments.pictogram );
		super.getCacheManager().remove( getCacheScope(), arguments.pictogram.getId() );

		return arguments.pictogram.getId();
	}

	public com.apirone.core.model.bean.Outcome function delete( required String pictogramId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.pictogramId );

		outcome.setData( { pictogramId = arguments.pictogramId } );

		transaction {
			try {
				var result = getDao().delete( arguments.pictogramId );
				outcome.setData( { "deletedCount" = result } )

				super.logEvent(
					event   = "pictogram.deleted",
					message = "Pictogram [#arguments.pictogramId#] deleted",
					payload = { "id" = arguments.pictogramId }
				);

				super.getCacheManager().remove( getCacheScope(), arguments.pictogramId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeletePictogram" );
				outcome.setMessage( "Cannot delete Pictogram [#arguments.pictogramId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.Pictogram function build( required String pictogramId ){
		var record = getDao().read( arguments.pictogramId );

		if ( record.recordCount ) {
			var bean = super.bean( "Pictogram" );

			bean.setId( record.pictogram_id );
			
			bean.setCode( getLookupService().get( "PictogramCode", record.code ).getId() );
			bean.setName( getLookupService().get( "PictogramCode", record.code ).getName() );
			
			var images = getFileService().list( pictogramId = record.pictogram_id );

			if ( Len( images ) ) {
				bean.setImage( images[1] )
			}

			bean.setFontFamilyId( record.font_family_id )

			return bean;
		}

		return NullValue();
	}

}
