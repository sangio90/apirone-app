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

		// Il find() restituisce tutte le colonne: si raccolgono gli ID per getMany()
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie gli ID e carica i bean in blocco con getMany()
		var ids = [];
		records.each( function( record ){
			ids.append( record.permission_id );
		} );

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.permission_id ] );
		} );

		return rows;
	}

	/**
	 * Recupera in batch più Permission dato un array di ID.
	 * Restituisce uno Struct chiave = permissionId, valore = bean Permission.
	 * Precarica l'Entity (Lookup) in batch locale - LookupService è già in-memory.
	 *
	 * @ids Array di permissionId
	 * @return Struct mappato per permissionId -> Permission
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};
		var entities = {};

		for ( var record in records ) {
			var bean = super.bean( "Permission" );

			// Campi diretti dal record
			bean.setId( record.permission_id );
			bean.setName( record.permission );
			bean.setCreatedAt( record.created_at );

			// Entity (Lookup): cached localmente (LookupService è in-memory)
			if ( !StructKeyExists( entities, record.entity_id ) ) {
				entities[ record.entity_id ] = getLookupService().get( "entity", record.entity_id );
			}
			bean.setEntity( entities[ record.entity_id ] );

			map[ bean.getId() ] = bean;
		}

		return map;
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
