// interceptors/SecurityInterceptor.cfc
component extends="coldbox.system.Interceptor" {

	// property name="userService" inject="userService";
	//property name="securityService" inject="SecurityService";

	function preProcess( event, rc, prc ){
		// --- A. Preparazione dei dati ---

		var securityService = server["wirebox-apirone"].getInstance("securityService");

		//abort;

		// Recupera l'utente loggato. Assumiamo che restituisca un oggetto User
		// che risponde al metodo .hasPermission().
		var user = session.user;

		var module     = event.getCurrentModule();
		var eventName  = event.getCurrentEvent();
		var controller = event.getCurrentHandler();

		if ( module == "api" ) {
			storeRequest( event )

			var svc = model.getInstance( "APIService" );

			try {
				var authToken = Trim( GetHTTPRequestData().Headers.authorization.replace( "Bearer", "" ) );

				// used by Verticale
				if ( authToken != "9e39d8edd05940ddab24411338e9def857679e76978041e29a1d7f956aa0be5d" ) {
					return arguments.event
						.renderData(
							data       = "Not Authorized. Token not valid.",
							statusCode = "401",
							statusText = "Unauthorized"
						)
						.noExecution();
				}
			} catch ( e ) {
				return arguments.event
					.renderData(
						data       = "Not Authorized.",
						statusCode = "401",
						statusText = "Unauthorized"
					)
					.noExecution();
			}
		}

		if ( module == "manager" ) {
			// Chiama il SecurityService per verificare i permessi.
			if ( !securityService.canAccess( user, eventName ) ) {
				var controller = event.getCurrentHandler();

				if ( controller CONTAINS "ajax" ) {
					return arguments.event
						.renderData(
							data       = "Not Authorized.",
							statusCode = "401",
							statusText = "Unauthorized"
						)
						.noExecution();
				} else {
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
				}
				event.noRender(); // Assicura che ColdBox non provi a renderizzare l'evento bloccato
				return;
			} 
		}

		// TODO: manage here other modules. stop execution if not allowed

		// Se hasAccess è true, l'esecuzione continua normalmente.
	}

}
