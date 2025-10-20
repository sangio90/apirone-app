component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FontFamilyDAO";
	property name="textService" inject="TextService";
	property name="pictogramService" inject="PictogramService";

	property name="cacheScope" type="String" default="FontFamily.bean";

	public com.apirone.core.model.bean.FontFamily function get( required String fontFamilyId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.fontFamilyId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.fontFamilyId );
		cm.put( getCacheScope(), arguments.fontFamilyId, bean );

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
		required Array orderBy  = [ { field = "fontFamily.code" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderby );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( fontFamilyId = record.font_family_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.font_family_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	/**
	 * @auditEvent FONT_FAMILY.created
	 * @auditMessage Font Family [@return@] created
	 * @auditPayload { "id": "@return@" }
	 */
	public String function create( required com.apirone.core.model.bean.FontFamily fontFamily){
		var newId = getDao().insert( arguments.fontFamily );
		return newId;
	}

	/**
	 * @auditEvent FONT_FAMILY.updated
	 * @auditMessage Font Family [@fontFamily.id@] updated
	 * @auditPayload { "id": "@fontFamily.id@" }
	 */
	public String function update( required com.apirone.core.model.bean.FontFamily fontFamily ){
		getDao().update( arguments.fontFamily );
		super.getCacheManager().remove( getCacheScope(), arguments.fontFamily.getId() );

		return arguments.fontFamily.getId();
	}

	public com.apirone.core.model.bean.Outcome function delete( required String fontFamilyId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.fontFamilyId );

		outcome.setData( { fontFamilyId = arguments.fontFamilyId } );

		var result = getDao().delete( arguments.fontFamilyId );
		outcome.setData( { "deletedCount" = result } )

		super.logEvent(
			event   = "FONT_FAMILY.deleted",
			message = "Font [#arguments.fontFamilyId#] deleted",
			payload = { "id" = arguments.fontFamilyId }
		);

		super.getCacheManager().remove( getCacheScope(), arguments.fontFamilyId );

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.FontFamily function build( required String fontFamilyId ){
		var record = getDao().read( arguments.fontFamilyId );

		if ( record.recordCount ) {
			var bean = super.bean( "FontFamily" );

			bean.setId( record.font_family_id );
			bean.setCode( record.code );
			bean.setName( record.font_family );

			var pictograms = getPictogramService().list( fontFamilyId = arguments.fontFamilyId );
			if ( Len( pictograms ) ) {
				bean.setPictograms( pictograms )
			}

			return bean;
		}

		return NullValue();
	}

}
