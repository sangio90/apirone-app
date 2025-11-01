component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="lookupService" inject="LookupService";

	property name="cacheScope" type="String" default="Permission.bean";

	public com.apirone.core.model.bean.Permission function get( permission ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.permission.id );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.permission );
		cm.put( getCacheScope(), arguments.permission.id, bean );

		return bean;
	}

	public Array function list( String permissionId, String entityId ){
		var rows        = [];
		var result      = super.getResult();
		var permissions = DeserializeJSON( FileRead( "/config/data/permissions.json.cfm" ) );

		if ( !IsNull( entityId ) ) {
			permissions = permissions.filter( function( item ){
				return item.entityId == entityId;
			} );
		}

		if ( !IsNull( permissionId ) ) {
			permissions = permissions.filter( function( item ){
				return item.id == permissionId;
			} );
		}

		permissions.each( function( record ){
			rows.add( get( record ) );
		} );

		return rows;
	}

	private com.apirone.core.model.bean.Permission function build( required permission ){
		var bean = super.bean( "Permission" );

		bean.setId( permission.id );

		bean.setName( permission.name );
		bean.setEntity( getLookupService().get( "entity", permission.entityId ) );

		return bean;
	}

}
