component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="SignageConfigDAO";
	property name="fontService" inject="fontService";
	property name="catalogBundleService" inject="catalogBundleService";
	property name="signageConfigItemService" inject="signageConfigItemService";

	property name="cacheScope" type="String" default="SignageConfig.bean";

	public com.apirone.core.model.bean.SignageConfig function get( required String signageConfigId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.signageConfigId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.signageConfigId );
		cm.put(
			getCacheScope(),
			arguments.signageConfigId,
			bean
		);

		return bean;
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

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( signageConfigId = record.signage_config_id ) );
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
			getSignageConfigItemService().create( item );
		}

		// TODO: optimize cache invalidation
		getCacheManager().removeAll();

		return newId;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String signageConfigId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.signageConfigId );

		outcome.setData( { signageConfigId = arguments.signageConfigId } );

		transaction {
			try {
				var result = getDao().delete( arguments.signageConfigId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.signageConfigId );
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

	private com.apirone.core.model.bean.SignageConfig function build( required String signageConfigId ){
		var record = getDao().read( arguments.signageConfigId );

		if ( record.recordCount ) {
			var bean = super.bean( "SignageConfig" );

			bean.setId( record.signage_config_id );
			bean.setCreatedAt( record.created_at );

			bean.setFont( getFontService().get( record.font_id ) );
			bean.setCatalogBundle( getCatalogBundleService().get( record.catalog_bundle_id ) );
			bean.setItems( getSignageConfigItemService().list( record.signage_config_id ) );


			return bean;
		}

		return NullValue();
	}

}
