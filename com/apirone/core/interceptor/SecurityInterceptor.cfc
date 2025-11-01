// interceptors/SecurityInterceptor.cfc
component extends="coldbox.system.Interceptor" {

	// property name="userService" inject="userService";
	property name="securityService" inject="SecurityService";

	function preProcess( event, rc, prc ){
		// --- A. Preparazione dei dati ---

		// Recupera l'utente loggato. Assumiamo che restituisca un oggetto User
		// che risponde al metodo .hasPermission().
		var user = session.user;

		var eventName = event.getCurrentEvent();


		// Chiama il SecurityService per verificare i permessi.
		if ( !securityService.canAccess( user, eventName ) ) {
			if ( user.isLogged() ) {
				// alla dashbord con messaggio

				// TODO: move to an helper, like in AbsController
				flash.put(
					"message",
					{
						"type"    = "warning",
						"message" = "Accesso negato. Non hai i permessi necessari per accedere a #eventName#",
						"title"   = "Accesso negato"
					}
				);

				relocate(
					uri               = "/manager/dashboard",
					postProcessExempt = false,
					addToken          = false
				);
			} else {
				relocate(
					uri               = "/manager/login",
					postProcessExempt = false,
					addToken          = false
				);
			}

			event.noRender(); // Assicura che ColdBox non provi a renderizzare l'evento bloccato
			return;
		}

		// Se hasAccess è true, l'esecuzione continua normalmente.
	}

}
