component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="lookupService" inject="LookupService";

	property name="cacheScope" type="String" default="Permission.bean";

	public com.apirone.core.model.bean.Permission function get( permission ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.permission.id );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.permission );
		cm.put( getCacheScope(), arguments.permission.id, bean );

		return bean;
	}

	public Array function list( String permissionId, String entityId ){
		var rows        = [];
		var result      = super.getResult();
		var permissions = DeserializeJSON( FileRead( "/config/data/permissions.json.cfm" ) );

		if ( !IsNull( entityId ) ) {
			permissions = permissions.filter( function( item ){
				return item.entityId == entityId;
			} );
		}

		if ( !IsNull( permissionId ) ) {
			permissions = permissions.filter( function( item ){
				return item.id == permissionId;
			} );
		}

		permissions.each( function( record ){
			rows.add( get( record ) );
		} );

		return rows;
	}

	public Boolean function canDo( required array requiredPermissions, required Struct user ){
		// 1. Estrai i permessi dell'utente dalla struttura
		var userPermissions = user.getPermissions(); // Supponiamo che l'utente abbia un metodo getPermissions() che restituisce un array di permessi

		// 2. CHECK ADMIN DI ALTO LIVELLO (Bypass)
		// Se l'utente ha l'attributo isAdmin = true, l'accesso è concesso immediatamente.
		if ( user.getRole().getId() == "ADM" ) {
			return true;
		}

		// 3. CHECK PERMESSI RICHIESTI

		// Se non sono richiesti permessi (e l'utente non è admin), neghiamo l'accesso (basandoci sul tuo modello "negato di default")
		if ( !ArrayLen( requiredPermissions ) ) {
			return false;
		}

		// 4. Gestione del permesso speciale "all"
		if ( ArrayFind( requiredPermissions, "all" ) ) {
			return true;
		}

		// 5. Verifica dei permessi reali (logica OR)
		for ( var requiredPerm in requiredPermissions ) {
			// Se l'utente possiede anche solo uno dei permessi richiesti
			if ( ArrayFind( userPermissions, requiredPerm ) ) {
				return true;
			}
		}

		// 6. Fallback: Nessun accesso
		return false;
	}


	private com.apirone.core.model.bean.Permission function build( required permission ){
		var bean = super.bean( "Permission" );

		bean.setId( permission.id );

		bean.setName( permission.name );
		bean.setEntity( getLookupService().get( "entity", permission.entityId ) );

		return bean;
	}

}
