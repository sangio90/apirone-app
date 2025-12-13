component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	variables.permissionRoutes   = {};
	variables.DEFAULT_POLICY_KEY = "DEFAULT_POLICY";

	public SecurityService function init( permissionRoutesPath = "/config/permissionRoutes.json.cfm" ){
		variables.permissionRoutes = DeserializeJSON( FileRead( ExpandPath( permissionRoutesPath ) ) );

		return this;
	}

	public boolean function canAccess( required any user, required string eventName ){
		// return true;
		var baseEventName = arguments.eventName;
		if ( ListContains( arguments.eventName, ":" ) ) {
			baseEventName = ListLast( arguments.eventName, ":" );
		}

		// 1. Ottieni l'intera configurazione (che ora include 'required' e 'roles')
		var routeConfig         = getRouteConfig( baseEventName );
		var requiredPermissions = routeConfig.required ?: []; // Usa il default se non specificato
		var requiredRoles       = routeConfig.roles ?: []; // Nuovo: array dei ruoli richiesti

		// --- Livello 3: Accesso Libero (se entrambi gli array sono vuoti) ---
		if ( ArrayIsEmpty( requiredPermissions ) && ArrayIsEmpty( requiredRoles ) ) {
			return true;
		}

		// --- Livello 2: Autenticazione Implicita ---
		// Se si richiedono Ruoli O Permessi, DEVE essere un utente loggato.
		if ( !user.isLogged() ) {
			return false;
		}

		// --- Livello 1A: Verifica Ruoli ---
		// Se sono richiesti ruoli, l'utente DEVE avere ALMENO UNO dei ruoli richiesti.
		if ( !ArrayIsEmpty( requiredRoles ) ) {
			var hasRequiredRole = false;
			for ( var role in requiredRoles ) {
				if ( user.getRole().getId() == role ) {
					// Metodo ipotetico nell'oggetto utente
					hasRequiredRole = true;
					break;
				}
			}
			if ( !hasRequiredRole ) {
				return false; // Non ha nessun ruolo richiesto
			}
		}

		// --- Livello 1B: Verifica Permessi Specifici ---
		// Se sono richiesti permessi, l'utente DEVE averli tutti.
		for ( var permission in requiredPermissions ) {
			if ( !user.hasPermission( permission ) ) {
				return false;
			}
		}

		// Autenticato e ha soddisfatto i requisiti di Ruolo E Permesso.
		return true;
	}

	// 🔧 Modifica la funzione per restituire l'intera configurazione (struct)
	private struct function getRouteConfig( required string eventName ){
		// 1. Cerca Corrispondenza Esatta
		if ( StructKeyExists( variables.permissionRoutes, arguments.eventName ) ) {
			return variables.permissionRoutes[ arguments.eventName ];
		}

		// 2. Cerca Corrispondenza Wildcard
		for ( var pattern in variables.permissionRoutes ) {
			if ( pattern.endsWith( ".*" ) ) {
				var prefix = pattern.replace( ".*", "", "one" );
				if ( arguments.eventName.startsWith( prefix & "." ) ) {
					return variables.permissionRoutes[ pattern ];
				}
			}
		}

		// 3. APPLICA LA POLICY DI DEFAULT
		if ( StructKeyExists( variables.permissionRoutes, variables.DEFAULT_POLICY_KEY ) ) {
			return variables.permissionRoutes[ variables.DEFAULT_POLICY_KEY ];
		}

		// 4. DENY ALL: Configurazione di fallback per negare.
		return { required = [ "DENY_ACCESS" ], roles = [] };
	}
	

}
