// interceptors/SecurityInterceptor.cfc
component extends="coldbox.system.Interceptor" {

	property name="userService" inject="userService";
	property name="permissionService" inject="permissionService";

	function preProcess( event, rc, prc ){
		// 1. Ottieni la rotta corrente

		/*
		var currentRoute = prc.currentRouteRecord;

		// Se non c'è una rotta (es. errore 404), o non è una rotta registrata, procedi
		if ( !IsStruct( currentRoute ) ) {
			return;
		}

		// 2. Estrai i permessi richiesti dalla rotta
		var requiredPermissions = StructKeyExists( currentRoute.prc, "permissions" )
		 ? ListToArray( currentRoute.prc.permissions )
		 : [];

		// Se non sono richiesti permessi espliciti, concedi l'accesso (modello "aperto")
		if ( !ArrayLen( requiredPermissions ) ) {
			return;
		}

		// Assumiamo che l'utente sia già autenticato e che il suo ID sia in sessione o simile.
		session.user;

		// In un'app reale, userPermissions conterrà sia ruoli che permessi specifici
		// var userPermissions = userService.getPermissionsByUserID( argumentCollection = { userID = userID } );
		// prc.put( "userPermissions", userPermissions ); // Utile per il MenuService!

		// --- 4. Logica di Verifica ---

		var hasAccess = false;

		// 4. Logica di Verifica Centralizzata
		var hasAccess = permissionService.canDo( requiredPermissions = requiredPermissions, user = session.user );

		// 5. Azione in caso di Accesso Negato
		if ( !hasAccess ) {
			// Puoi usare uno dei metodi di ColdBox per gestire il rifiuto:

			// Se l'utente non è loggato, reindirizza al login
			if ( !userID ) {
				event.relocate( route = "main.login" );
				return false; // Ferma l'esecuzione
			}

			// Se l'utente è loggato ma non ha i permessi, reindirizza a una pagina 403 (Forbidden)
			event.setHTTPResponse( status = 403, statusText = "Forbidden" );
			event.setView( view = "shared/403" ); // Mostra la vista 403
			return false; // Ferma l'esecuzione
		}
		*/

		// Se hasAccess è true, l'esecuzione continua normalmente.
	}

}
