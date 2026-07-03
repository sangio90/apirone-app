component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="RoleDAO";
	property name="rolePermissionService" inject="RolePermissionService";
	property name="lookupService" inject="LookupService";

	public com.apirone.core.model.bean.Role function get( required String roleId ){
		return build( arguments.roleId );
	}

	public Array function list(
		String str,
		required Array orderBy  = [ { field = "role.id", desc = "asc" } ]
	){

		var rows   = [];

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e costruisce i bean in batch con getMany()
		var ids = [];
		records.each( function( record ){
			ids.append( record.role_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			if ( StructKeyExists( beanMap, record.role_id ) ) {
				rows.add( beanMap[ record.role_id ] );
			}
		} );

		return rows;
	}

	/**
	 * Recupera in batch più Role dato un array di ID.
	 * Restituisce uno Struct chiave = roleId, valore = bean Role.
	 * Precarica RolePermission e roleType in batch per evitare il problema N+1.
	 *
	 * @ids Array di roleId
	 * @return Struct mappato per roleId -> Role
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Precarica le RolePermission in batch per tutti i role_id
		var permissionMap = {};
		if ( ArrayLen( arguments.ids ) ) {
			var permRecords = getRolePermissionService().getDao().readByRoleIds( roleIds = arguments.ids );
			for ( var permr in permRecords ) {
				var roleId = permr.role_id;
				if ( !StructKeyExists( permissionMap, roleId ) ) {
					permissionMap[ roleId ] = [];
				}
				var permBean = super.bean( "RolePermission" );
				permBean.setId( permr.role_permission_id );
				permBean.setRoleId( permr.role_id );
				permBean.setCreatedAt( permr.created_at );
				ArrayAppend( permissionMap[ roleId ], permBean );
			}
		}

		// Cache locale per roleType (LookupService è in-memory)
		var types = {};

		for ( var record in records ) {
			var bean = super.bean( "Role" );

			// Campi diretti dal record
			bean.setName( record.role );
			bean.setId( record.role_id );
			bean.setCreatedAt( record.created_at );
			bean.setQuotationMaxDiscount( record.quotation_max_discount );
			bean.setQuotationMaxAmount( record.quotation_max_amount );

			// Type: LookupService in-memory, cached localmente
			if ( !StructKeyExists( types, record.role_type_id ) ) {
				types[ record.role_type_id ] = getLookupService().get( "roleType", record.role_type_id );
			}
			bean.setType( types[ record.role_type_id ] );

			// Permissions: dalla mappa pre-caricata
			if ( StructKeyExists( permissionMap, record.role_id ) && ArrayLen( permissionMap[ record.role_id ] ) ) {
				bean.setPermissions( permissionMap[ record.role_id ] );
			}

			map[ record.role_id ] = bean;
		}

		return map;
	}

	public String function create( required com.apirone.core.model.bean.Role role ){
		var newId = getDao().insert( arguments.role );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.Role role ){
		getDao().update( arguments.role );

		return arguments.role.getId();
	}


	/*
		private methods
	*/

	/**
	 * Costruisce un bean Role a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.Role function build( required String roleId ){
		var record = getDao().read( arguments.roleId );

		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Role a partire da una riga della query.
	 * Le sub-entity (roleType, permissions) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.Role function buildFromFindRow( required any record ){
		var bean = super.bean( "Role" );

		// Campi diretti dal record
		bean.setName( record.role );
		bean.setId( record.role_id );
		bean.setCreatedAt( record.created_at );
		bean.setQuotationMaxDiscount( record.quotation_max_discount );
		bean.setQuotationMaxAmount( record.quotation_max_amount );

		// Entity collegate (caricate singolarmente)
		bean.setType( getLookupService().get( "roleType", record.role_type_id ) );
		bean.setPermissions( getRolePermissionService().list( roleId = record.role_id ) );

		return bean;
	}

}
