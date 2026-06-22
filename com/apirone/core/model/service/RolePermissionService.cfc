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

		// Il find() restituisce tutte le colonne: si raccolgono gli ID per getMany()
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie gli ID e carica i bean in blocco con getMany()
		var ids = [];
		records.each( function( record ){
			ids.append( record.role_permission_id );
		} );

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.role_permission_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più RolePermission dato un array di ID.
	 * Restituisce uno Struct chiave = rolePermissionId, valore = bean RolePermission.
	 * Precarica i Permission in batch locale per evitare il problema N+1.
	 *
	 * @ids Array di rolePermissionId
	 * @return Struct mappato per rolePermissionId -> RolePermission
	 */
	public Struct function getMany( required Array ids ){
		var records     = getDao().readByIds( ids = arguments.ids );
		var map         = {};
		var permissions = {};

		for ( var record in records ) {
			var bean = super.bean( "RolePermission" );

			// Campi diretti dal record
			bean.setId( record.role_permission_id );
			bean.setRoleId( record.role_id );
			bean.setCreatedAt( record.created_at );

			// Permission: cached localmente per evitare chiamate N+1
			if ( !StructKeyExists( permissions, record.permission_id ) ) {
				permissions[ record.permission_id ] = getPermissionService().get( record.permission_id );
			}
			bean.setPermission( permissions[ record.permission_id ] );

			map[ bean.getId() ] = bean;
		}

		return map;
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


	/**
	 * Costruisce un bean RolePermission a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
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
