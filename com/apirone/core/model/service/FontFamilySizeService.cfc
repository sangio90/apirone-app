component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FontFamilySizeDAO";

	property name="cacheScope" type="String" default="FontFamilySize.bean";

	public com.apirone.core.model.bean.FontFamilySize function get( required String fontFamilySizeId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.fontFamilySizeId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.fontFamilySizeId );

		cm.put(
			getCacheScope(),
			arguments.fontFamilySizeId,
			bean
		);

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String fontFamilyId,
		
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "fontFamilySize.id" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderby );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( fontFamilySizeId = record.font_family_size_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.FontFamilySize fontFamilySize ){
		var newId = getDao().insert( arguments.fontFamilySize );
		return newId;
	}

	public String function update( required com.apirone.core.model.bean.FontFamilySize fontFamilySize ){
		getDao().update( arguments.fontFamilySize );
		super.getCacheManager().remove( getCacheScope(), arguments.fontFamilySize.getId() );

		return arguments.fontFamilySize.getId();
	}

	public com.apirone.core.model.bean.Outcome function delete( required String fontFamilySizeId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.fontFamilySizeId );

		outcome.setData( { fontFamilySizeId = arguments.fontFamilySizeId } );

		var result = getDao().delete( arguments.fontFamilySizeId );
		outcome.setData( { "deletedCount" = result } )

		super.logEvent(
			event   = "FONT_FAMILY_SIZE.deleted",
			message = "Font [#arguments.fontFamilySizeId#] deleted",
			payload = { "id" = arguments.fontFamilySizeId }
		);

		super.getCacheManager().remove( getCacheScope(), arguments.fontFamilySizeId );

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.FontFamilySize function build( required String fontFamilySizeId ){
		var record = getDao().read( arguments.fontFamilySizeId );

		if ( record.recordCount ) {
			var bean = super.bean( "FontFamilySize" );

			bean.setId( record.font_family_size_id );
			bean.setName( record.font_family_size );
			bean.setFontFamilyId( record.font_family_id );
			bean.setEnabledPictograms( record.enabled_pictograms );

			return bean;
		}

		return NullValue();
	}

}
