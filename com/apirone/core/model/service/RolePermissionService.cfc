component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="RolePermissionDAO";
	property name="lookupService" inject="lookupService";
	property name="roleService" inject="RoleService";

	property name="cacheScope" type="String" default="RolePermission.bean";

	public com.apirone.core.model.bean.RolePermission function get( required String rolePermissionId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.rolePermissionId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.rolePermissionId );
		cm.put( getCacheScope(), arguments.rolePermissionId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String roleId,
		String permissionId,
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( rolePermissionid = record.role_permission_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.RolePermission rolePermission ){
		var newId = getDao().insert( arguments.rolePermission );

		getRoleService().removeCache( arguments.rolePermission.getRoleId() );

		return newId;
	}


	public com.apirone.core.model.bean.Outcome function delete( required String rolePermissionId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { rolePermissionId = arguments.rolePermissionId } );

		transaction {
			try {
				var result = getDao().delete( arguments.rolePermissionId );
				outcome.setData( { "deletedCount" = result } )
				super.getCacheManager().remove( getCacheScope(), arguments.rolePermissionId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteRolePermission" );
				outcome.setMessage( "Cannot delete Role Permission [#arguments.rolePermissionId#]" );
			}
		}

		return outcome;
	}

	private com.apirone.core.model.bean.RolePermission function build( required String rolePermissionId ){
		var record = getDao().read( arguments.rolePermissionId );

		if ( record.recordCount ) {
			var bean = super.bean( "RolePermission" );

			bean.setId( record.role_permission_id );
			bean.setPermission( getLookupService().get( "permission", record.permission_id ) );
			bean.setRoleId( record.role_id );
			bean.setActive( true );

			return bean;
		}

		return NullValue();
	}

}
