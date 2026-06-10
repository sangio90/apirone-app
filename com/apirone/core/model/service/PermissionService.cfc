component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PermissionDAO";
	property name="lookupService" inject="LookupService";

	public com.apirone.core.model.bean.Permission function get( required String permissionId ){
		return build( arguments.permissionId );
	}

	public Array function list(
		String str,
		String permissionId,
		String entityId,
		required Array orderBy  = [ { field = "permission.id", desc = "asc" } ]
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

	/**
	 * Costruisce un bean Permission a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.Permission function build( required String permissionId ){
		var record = getDao().read( arguments.permissionId );

		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Permission a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.Permission function buildFromFindRow( required any record ){
		var bean = super.bean( "Permission" );

		// Campi diretti dal record
		bean.setId( record.permission_id );
		bean.setName( record.permission );
		bean.setCreatedAt( record.created_at );

		// Entity collegata
		bean.setEntity( getLookupService().get( "entity", record.entity_id ) );

		return bean;
	}

}
