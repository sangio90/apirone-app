component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="SignageConfigDAO";
	property name="fontService" inject="fontService";
	property name="catalogBundleService" inject="catalogBundleService";
	property name="signageConfigItemService" inject="signageConfigItemService";

	public com.apirone.core.model.bean.SignageConfig function get( required String signageConfigId ){
		return build( arguments.signageConfigId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String catalogBundleId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "signageConfig.id", desc = "desc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.signage_config_id );
		} );

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );

			allRecords.each( function( r ){
				beanMap[ r.signage_config_id ] = buildFromRow( r );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.signage_config_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Numeric function create( required com.apirone.core.model.bean.SignageConfig signageConfig ){
		if ( !Len( signageConfig.getCatalogBundle().getId() ) ) {
			var catalogBundle = getCatalogBundleService().getOrCreate( signageConfig.getCatalogBundle() );

			signageConfig.getCatalogBundle().setId( catalogBundle.getId() );
		}

		var newId = getDao().insert( arguments.signageConfig );

		for ( var item in arguments.signageConfig.getItems() ) {
			item.setSignageConfigId( newId );

			if ( Len( item.getId() ) ) {
				getSignageConfigItemService().update( item );
			} else {
				getSignageConfigItemService().create( item );
			}
		}

		return newId;
	}

	public Numeric function update( required com.apirone.core.model.bean.SignageConfig signageConfig ){
		// var newId = getDao().update( arguments.signageConfig );

		for ( var item in arguments.signageConfig.getItems() ) {
			item.setSignageConfigId( signageConfig.getId() );

			if ( Len( item.getId() ) ) {
				getSignageConfigItemService().update( item );
			} else {
				getSignageConfigItemService().create( item );
			}
		}

		return signageConfig.getId();
	}

	public com.apirone.core.model.bean.Outcome function delete( required String signageConfigId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.signageConfigId );

		outcome.setData( { signageConfigId = arguments.signageConfigId } );

		transaction {
			try {
				var result = getDao().delete( arguments.signageConfigId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteSignageConfig" );
				outcome.setMessage( "Cannot delete signageConfig [#arguments.signageConfigId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	/**
	 * Costruisce un bean SignageConfig a partire dall'ID. Delega a buildFromRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.SignageConfig function build( required String signageConfigId ){
		var record = getDao().read( arguments.signageConfigId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean SignageConfig a partire da una riga del query.
	 * Le sub-entity (Font, CatalogBundle, SignageConfigItems) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.SignageConfig function buildFromRow( required any record ){
		var bean = super.bean( "SignageConfig" );

		// Campi diretti dal record
		bean.setId( arguments.record.signage_config_id );
		bean.setCreatedAt( arguments.record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setFont( getFontService().get( arguments.record.font_id ) );
		bean.setCatalogBundle( getCatalogBundleService().get( arguments.record.catalog_bundle_id ) );
		bean.setItems( getSignageConfigItemService().list( arguments.record.signage_config_id ) );

		return bean;
	}

}
