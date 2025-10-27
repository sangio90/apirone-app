component extends="com.apirone.core.controller.AbsController" {

	property name="lookupService" inject="lookupService";

	function list( event, rc, prc ){
		var data = [];
		var result = super.getResult();
		var mm     = super.getMementify();
		var params = super.paramsFromUrl();

		var rows = super.fire( "permission.list", params );
		var role = super.fire( "role.get", [ rc.roleId ] );
		for ( var row in rows ) {
			var rolePermission = super.bean( "RolePermission" );
			rolePermission.setPermission( row );
			rolePermission.setRoleId( rc.roleId );
			rolePermission.setActive(false);

			for ( var permission in role.getPermissions() ) {
				if ( row.getId() == permission.getPermission().getId() ) {
					rolePermission.setActive(true);
					break;
				}
			}
			
			var obj = mm.convert( rolePermission, "list" );
			data.add( obj );
		}

		result.setTotal( data.len() );
		result.setCount( data.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId    = "";
		var messageId = "";

		var result = super.getResult();

		var permissions = json.entity.permissions;

		transaction {
			for ( var permission in permissions ) {
				var existingPermission = super.fire( "rolePermission.list", { "roleId" = json.id, "permissionId" = permission.permission.id } )	
				if ( !isNull(existingPermission) && existingPermission.len() > 0 && permission.active == false ) {
					var existingId = existingPermission.getData()[1].getId()
					super.fire( "rolePermission.delete", [ existingId ] )
				}
				if (existingPermission.len() == 0 && permission.active == true) {
					var newPermission = super.bean( "rolePermission" );
					var role = super.fire( "role.get", [ json.id ] );
					newPermission.setRoleId( json.id );
					newPermission.setPermission( super.fire( "lookup.get", [ "permission", permission.permission.id ] ) );
					thisId = super.fire( "rolePermission.create", [ newPermission ] )	
					messageId = "rolePermission.created";
				}
			}
		}
		
		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}
}
