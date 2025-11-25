component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="StatusDAO";
	property name="systemColorService" inject="systemColorService";

	property name="CacheScope" type="String" default="Status.bean";

	public com.apirone.core.model.bean.Status function get( required String statusId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.statusId );

		if ( cache.status ) {
			return cache.data;
		}

		var obj = build( arguments.statusId );

		cm.put( getCacheScope(), statusId, obj );

		return obj;
	}

	public Array function list(){
		var rows = [];

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( record.status_id ) );
		} );

		return rows;
	}

	/*
    	private method
	*/

	private com.apirone.core.model.bean.Status function build( required String statusId ){
		var record = getDao().read( arguments.statusId );

		if ( record.RecordCount ) {
			var obj = super.bean( "Status" );

			obj.setId( record.status_id );
			obj.setName( record.status );
			obj.setOrderBy( record.orderby );
			obj.setColor( getSystemColorService().get( record.color_id ) );

			return obj;
		}

		return NullValue();
	}

}
