component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="TextKindDAO";
	property name="cacheScope" type="String" default="TextKind.bean";

	public com.apirone.core.model.bean.TextKind function get( required String textKindId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.textKindId );

		if ( cache.status ) {
			return cache.data;
		}

		var obj = build( arguments.textKindId );

		cm.put( getCacheScope(), arguments.textKindId, obj );

		return obj;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( textKindId = record.text_kind_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * private methods
	 */
	private com.apirone.core.model.bean.TextKind function build( required String textKindId ){
		var record = getDao().read( textKindId = arguments.textKindId );

		if ( record.RecordCount ) {
			var obj = super.bean( "TextKind" );

			obj.setId( record.text_kind_id );
			// obj.setName( record.name );

			return obj;
		}

		return NullValue();
	}

}
