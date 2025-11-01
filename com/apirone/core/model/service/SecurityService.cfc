component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	variables.permissionRoutes = {};

	public SecurityService function init( permissionRoutesPath = "/config/permissionRoutes.json.cfm" ){
		variables.permissionRoutes = DeserializeJSON( FileRead( ExpandPath( permissionRoutesPath ) ) );

		return this;
	}

	public boolean function canAccess( required any user, required string eventName ){
		var baseEventName = arguments.eventName;
		if ( ListContains( arguments.eventName, ":" ) ) {
			// può contenere il modulo, lo estrae ( da manager:product.save a product.save)
			baseEventName = ListLast( arguments.eventName, ":" );
		}

		var requiredPermissions = getRequiredPermissions( baseEventName );

		// 1. Livello 3: Accesso Libero (Array vuoto)
		if ( ArrayIsEmpty( requiredPermissions ) ) {
			return true;
		}

		// 2. Livello 2: Autenticazione Implicita
		// Se l'array NON è vuoto, DEVE essere un utente loggato.
		// Usiamo il tuo 'user' object per verificare lo stato di login.
		if ( !user.isLogged() ) {
			// Assumi che il tuo oggetto utente abbia questo metodo
			return false;
		}

		// 3. Livello 1: Verifica Permessi Specifici
		// L'utente è loggato; ora verifica i permessi reali richiesti.
		for ( var permission in requiredPermissions ) {
			if ( !user.hasPermission( permission ) ) {
				return false;
			}
		}

		// Autenticato e ha tutti i permessi specifici.
		return true;
	}

	private array function getRequiredPermissions( required string eventName ){
		// 1. Cerca Corrispondenza Esatta (l'evento preciso ha la massima priorità)
		if ( StructKeyExists( variables.permissionRoutes, arguments.eventName ) ) {
			// Restituisce l'array dei permessi richiesti
			return variables.permissionRoutes[ arguments.eventName ].required;
		}

		// 2. Cerca Corrispondenza Wildcard (e.g., product.*)
		for ( var pattern in variables.permissionRoutes ) {
			if ( pattern.endsWith( ".*" ) ) {
				var prefix = pattern.replace( ".*", "", "one" );

				// Controlla se l'eventName inizia con il prefisso + punto
				if ( arguments.eventName.startsWith( prefix & "." ) ) {
					// Trovata la regola di raggruppamento base, la usiamo e usciamo subito.
					return variables.permissionRoutes[ pattern ].required;
				}
			}
		}

		// se l'evento non c'è nel file di configurazione, l'accesso è negato
		return [ "DENY_BY_DEFAULT_ACCESS" ]; //
	}

}
