component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ColorDAO";
	property name="statusService" inject="StatusService";

	property name="cacheScope" type="String" default="Color.bean";

	public com.apirone.core.model.bean.Color function get( required String colorId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.colorId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.colorId );
		cm.put( getCacheScope(), arguments.colorId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String rawProductId,
		String variantId,
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record, index ){
			rows.add( get( colorId = record.clcodice ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordCount ) );
		result.setTotal( Val( 100 ) );

		return result;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.Color function build( required String colorId ){
		var bean = super.bean( "Color" );

		if ( arguments.colorId == "_NOCOL" ) {
			bean.setId( "_NOCOL" );
			bean.setName( "Nessun colore" );

			return bean;
		}

		var record = getDao().read( arguments.colorId );

		if ( record.recordCount ) {
			var record = trimQueryFields( record );

			bean.setId( record.clcodice );
			bean.setName( record.cldescri );

			return bean;
		}

		return NullValue();
	}

}
