component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="pictogramDimensionDAO";
	property name="lookupService" inject="LookupService";

	public com.apirone.core.model.bean.PictogramDimension function get( required String pictogramDimensionId ){
		return build( arguments.pictogramDimensionId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		required Numeric pictogramId,
		required Numeric limit  = 100,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "pictogram.id" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderby );

		// Il find() ora restituisce tutte le colonne: si possono costruire i bean direttamente
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( buildFromFindRow( record ) );
		} );

		result.setData( rows );
		result.setCount( records.recordcount );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.PictogramDimension pictogramDimension ){
		var newId = getDao().insert( arguments.pictogramDimension );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.PictogramDimension pictogramDimension ){
		var id = getDao().update( arguments.pictogramDimension );

		return id;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String pictogramDimensionId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.pictogramDimensionId );

		outcome.setData( { pictogramDimensionId = arguments.pictogramDimensionId } );

		transaction {
			try {
				var result = getDao().delete( arguments.pictogramDimensionId );
				outcome.setData( { "deletedCount" = result } )

				super.logEvent(
					event   = "pictogram.deleted",
					message = "Pictogram [#arguments.pictogramDimensionId#] deleted",
					payload = { "id" = arguments.pictogramDimensionId }
				);
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.erros.pictograDimension.CannotDeleteRecord" );
				outcome.setMessage( "Cannot delete pictogram dimension [#arguments.pictogramDimensionId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.pictogramDimension function build( required String pictogramDimensionId ){
		var record = getDao().read( arguments.pictogramDimensionId );

		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean PictogramDimension a partire da una riga della query, senza chiamata DB aggiuntiva.
	 */
	private com.apirone.core.model.bean.pictogramDimension function buildFromFindRow( required any record ){
		var bean = super.bean( "PictogramDimension" );

		// Campi diretti dal record (PictogramDimension non ha sub-entity)
		bean.setId( record.pictogram_dimension_id );
		bean.setWidth( record.width );
		bean.setheight( record.height );
		bean.setPictogramId( record.pictogram_id );
		bean.setFontFamilySizeId( record.font_family_size_id );

		return bean;
	}

}
