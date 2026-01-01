component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];
		
		var result = super.getResult();
		var memy   = super.getMementify();
		var params = super.paramsFromUrl();

		var rows = super.fire( "permission.list", params );
		var role = super.fire( "role.get", [ rc.roleId ] );

		for ( var row in rows ) {
			
			var bean = super.bean( "RolePermission" );

			bean.setPermission( row );
			bean.setRoleId( rc.roleId );

			var line = memy.convert( bean );
			line["active"] = false;

			if( !IsNull( role.getPermissions() ) ) {
				
				for ( var permission in role.getPermissions() ) {

					if ( row.getId() == permission.getPermission().getId() ) {
						
						line["active"] = true;
						line["createdAt"] = DateTimeFormat( permission.getCreatedAt(), "yyyy-MM-dd HH:mm:ss" );

						break;
					}
				
				}

			}

			data.add( line );
		}

		result.setTotal( data.len() );
		result.setCount( data.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId    = "";
		var messageId = "rolePermission.created";

		var result = super.getResult();

		var permissions = json.entity.permissions;

		for ( var permission in permissions ) {
			
			var existingPermission = super.fire( "rolePermission.list", 
										{ 	"roleId" = json.id, 
											"permissionId" = permission.permission.id 
										} 
									)	

			if ( !isNull(existingPermission) && existingPermission.len() > 0 && permission.active == false ) {
				var existingId = existingPermission[1].getId()
				super.fire( "rolePermission.delete", [ existingId ] )
			}

			if (existingPermission.len() == 0 && permission.active == true) {

				var newPermission = super.bean( "rolePermission" );
				var role = super.fire( "role.get", [ json.id ] );

				newPermission.setRoleId( json.id );
				newPermission.setPermission( super.fire( "lookup.get", [ "permission", permission.permission.id ] ) );
				thisId = super.fire( "rolePermission.create", [ newPermission ] )	

			}
		}
			
		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}
}
