component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="RoleDAO";
	property name="rolePermissionService" inject="RolePermissionService";
	property name="lookupService" inject="LookupService";
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

	public Array function list(
		String str,
		required Array orderBy  = [ { field = "role.id", desc = "asc" } ]
	){
		
		var rows   = [];

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( roleId = record.role_id ) );
		} );

		return rows;
	}

	public Void function removeCache( required com.apirone.core.model.bean.Role role ){
		var cm = super.getCacheManager();

		cm.remove( getCacheScope(), arguments.role.getId() );

	}

	public String function create( required com.apirone.core.model.bean.Role role ){
		var newId = getDao().insert( arguments.role );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.Role role ){
		getDao().update( arguments.role );
		super.getCacheManager().remove( getCacheScope(), arguments.role.getId() );

		return arguments.role.getId();
	}


	/*
		private methods
	*/

	private com.apirone.core.model.bean.Role function build( required String roleId ){
		var record = getDao().read( arguments.roleId );

		if ( record.recordCount ) {
			var bean = super.bean( "Role" );

			bean.setName( record.role );

			bean.setId( record.role_id );
			bean.setCreatedAt( record.created_at );
			bean.setType( getLookupService().get( "roleType", record.role_type_id ) );
			bean.setQuotationMaxDiscount( record.quotation_max_discount );
			bean.setQuotationMaxAmount( record.quotation_max_amount );

			bean.setPermissions( getRolePermissionService().list( roleId = arguments.roleId ) );

			return bean;
		}

		return NullValue();
	}

}
