component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PictogramDAO";
	property name="lookupService" inject="LookupService";
	property name="FileService" inject="FileService";

	public com.apirone.core.model.bean.Pictogram function get( required String pictogramId ){
		return build( arguments.pictogramId );
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

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( record ){
			ids.append( record.pictogram_id );
		} );

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );
			allRecords.each( function( record ){
				beanMap[ record.pictogram_id ] = buildFromRow( record );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.pictogram_id ] );
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
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Pictogram a partire da una riga della query, senza chiamata DB aggiuntiva
	 * per il record principale.
	 */
	public com.apirone.core.model.bean.Pictogram function buildFromRow( required any record ){
		var bean = super.bean( "Pictogram" );

		// Campi diretti dal record
		bean.setId( record.pictogram_id );
		bean.setFontFamilyId( record.font_family_id );

		// Entity collegate (caricate singolarmente)
		bean.setCode( getLookupService().get( "PictogramCode", record.code ).getId() );
		bean.setName( getLookupService().get( "PictogramCode", record.code ).getName() );

		var images = getFileService().list( pictogramId = record.pictogram_id );

		if ( Len( images ) ) {
			bean.setImage( images[1] )
		}

		return bean;
	}

}
