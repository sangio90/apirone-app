component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="RolePermissionDAO";
	property name="lookupService" inject="LookupService";
	property name="permissionService" inject="PermissionService";

	public com.apirone.core.model.bean.RolePermission function get( required String rolePermissionId ){
		return build( arguments.rolePermissionId );
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

		// Il find() ora restituisce tutte le colonne: si possono costruire i bean direttamente
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( buildFromFindRow( record ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.RolePermission rolePermission ){
		var newId = getDao().insert( arguments.rolePermission );

		return newId;
	}


	public com.apirone.core.model.bean.Outcome function delete( required String rolePermissionId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { rolePermissionId = arguments.rolePermissionId } );

		transaction {
			try {
				var result = getDao().delete( arguments.rolePermissionId );
				outcome.setData( { "deletedCount" = result } )
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
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean RolePermission a partire da una riga della query.
	 * La sub-entity Permission è caricata con chiamata individuale.
	 */
	private com.apirone.core.model.bean.RolePermission function buildFromFindRow( required any record ){
		var bean = super.bean( "RolePermission" );

		// Campi diretti dal record
		bean.setId( record.role_permission_id );
		bean.setRoleId( record.role_id );
		bean.setCreatedAt( record.created_at );

		// Entity collegata (Permission è caricato singolarmente)
		bean.setPermission( getPermissionService().get( record.permission_id ) );
		//bean.setActive( true );

		return bean;
	}

}
