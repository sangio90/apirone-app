component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PermissionDAO";
	property name="lookupService" inject="LookupService";

	property name="cacheScope" type="String" default="Permission.bean";

	public com.apirone.core.model.bean.Permission function get( required String permissionId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.permissionId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.permissionId );
		cm.put( getCacheScope(), arguments.permissionId, bean );

		return bean;
	}

	public Array function list(
		String str,
		String permissionId,
		String entityId,
		required Array orderBy  = [ { field = "permission.id", desc = "asc" } ]
	){
		
		var rows   = [];

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( permissionId = record.permission_id ) );
		} );

		return rows;
	}

	private com.apirone.core.model.bean.Permission function build( required String permissionId ){
		var record = getDao().read( arguments.permissionId );

		if ( record.recordCount ) {
			var bean = super.bean( "Permission" );

			bean.setId( record.permission_id );
			bean.setName( record.permission );
			bean.setCreatedAt( record.created_at );

			bean.setEntity( getLookupService().get( "entity", record.entity_id ) );

			return bean;
		}

		return NullValue();
	}

}