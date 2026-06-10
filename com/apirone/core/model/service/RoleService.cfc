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

		// Il find() ora restituisce tutte le colonne: si possono costruire i bean direttamente
		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( buildFromFindRow( record ) );
		} );

		return rows;
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
