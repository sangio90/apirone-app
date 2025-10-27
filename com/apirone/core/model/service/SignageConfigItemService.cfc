component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="SignageConfigItemDAO";
	property name="fontFamilySizeService" inject="FontFamilySizeService";

	property name="cacheScope" type="String" default="SignageConfigItem.bean";

	public com.apirone.core.model.bean.SignageConfigItem function get( required Numeric signageConfigItemId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.signageConfigItemId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.signageConfigItemId );
		cm.put(
			getCacheScope(),
			arguments.signageConfigItemId,
			bean
		);

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String signageConfigId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "SignageConfigItem.id", desc = "desc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( signageConfigItemId = record.signage_config_item_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Numeric function create( required com.apirone.core.model.bean.SignageConfigItem SignageConfigItem ){
		var newId = getDao().insert( arguments.SignageConfigItem );

		return newId;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String signageConfigItemId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.signageConfigItemId );

		outcome.setData( { signageConfigItemId = arguments.signageConfigItemId } );

		transaction {
			try {
				var result = getDao().delete( arguments.signageConfigItemId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.signageConfigItemId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteSignageConfigItem" );
				outcome.setMessage( "Cannot delete SignageConfigItem [#arguments.signageConfigItemId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.SignageConfigItem function build( required String signageConfigItemId ){
		var record = getDao().read( arguments.signageConfigItemId );

		if ( record.recordCount ) {
			var bean = super.bean( "SignageConfigItem" );
			bean.setSignageConfigId( record.signage_config_id );
			
			bean.setId( record.signage_config_item_id );
			bean.setCreatedAt( record.created_at );

			bean.setHeight( record.height );
			bean.setHeightInPixel( record.height_in_pixel );
			bean.setRowCount( record.row_count );
			bean.setCharCount( record.char_count );
            
            bean.setSize( getFontFamilySizeService().get( record.font_family_size_id ) );

			return bean;
		}

		return NullValue();
	}

}
