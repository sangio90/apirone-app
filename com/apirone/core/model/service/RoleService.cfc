component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="lookupService" inject="LookupService";
	property name="rolePermissionService" inject="RolePermissionService";

	public com.apirone.core.model.bean.Role function get( roleId ){
		var role = getLookupService().get( "role", roleId );
		var bean = build( role );

		return bean;
	}

	public com.apirone.core.model.bean.Result function list(
		String roleId
	){
		var rows = [];
		var result = super.getResult();
		var roles = DeserializeJSON( FileRead( "/config/data/roles.json.cfm" ) );

		if (!isNull(roleId)) {
			roles = roles.filter(function(item) {
				return item.id == roleId;
			});
		}

		roles.each( function ( record ){
			rows.add( get( record ) );
		}); 

		result.setData( rows );
		result.setTotal( Val( Len(roles) ) );
		result.setCount( Val( Len(roles) ) );

		return result;
	}


	private com.apirone.core.model.bean.Role function build( required role ){		
		var bean = super.bean( "Role" );

		bean.setId( role.getId() );

		bean.setName( role.getName() );
		bean.setPermissions( getRolePermissionService().list( roleId = role.getId() ) )
		
		return bean;
	}

}
