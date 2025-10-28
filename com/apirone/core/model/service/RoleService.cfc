component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	//property name="lookupService" inject="LookupService";
	property name="rolePermissionService" inject="RolePermissionService";
	property name="cacheScope" type="String" default="Role.bean";

	public com.apirone.core.model.bean.Role function get( required String roleId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.roleId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.roleId );
		cm.put( getCacheScope(), arguments.roleId, bean );

		return bean;
	}

	public Array function list(){
		
		var rows = [];
		
		var roles = getRawList();

		roles.each( function ( item ){
			rows.add( get( item.id ) );
		}); 

		return rows;
	}

	public Void function removeCache( required com.apirone.core.model.bean.Role role ){
		var cm = super.getCacheManager();

		cm.remove( getCacheScope(), arguments.role.getId() );

	}


	/*
		private methods
	*/

	private com.apirone.core.model.bean.Role function build( required roleId ){

		var bean = super.bean( "Role" );
		var role = getRawItem( roleId );

		bean.setId( role.id );
		bean.setName( role.name );

		bean.setPermissions( getRolePermissionService().list( roleId = role.id ) );
		
		return bean;
	}

	private Array function getRawList(){
		var list   = DeserializeJSON( FileRead( ExpandPath( "/config/data/roles.json.cfm" ) ) );

		return list;
	}

	private Struct function getRawItem( roleId ){
		var list = getRawList();

		for( var item in list ) {
			if( item.id == arguments.roleId ) {
				return item;
			}
		}

		return NullValue();
	}

}
