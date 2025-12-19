component extends="com.apirone.core.controller.AbsController" {

	function login( event, rc, prc ){
		if ( session.user.isLogged() ) {
			Location( "/manager/dashboard", false );
		}

		rc.email = StructKeyExists( cookie, "email" ) ? cookie.email : "";

		event.setView( "main/login" ).setLayout( "login" );
	}

	function pincode( event, rc, prc ){
		event.setView( "main/pincode" ).setLayout( "login" );
	}

	function recover( event, rc, prc ){
		event.setView( "main/recover" ).setLayout( "login" );
	}

	function checkPincode( event, rc, prc ){
		var user = prc.user;

		Location( "/manager/dashboard", false );
	}

	function checkRecover( event, rc, prc ){
		var user = prc.user;

		Location( "/manager/login/recover/check", false );
	}

	function checkLogin( event, rc, prc ){
		var user = prc.user;

		var access = super.fire( "auth.login", { "email" = rc.email, "pwd" = rc.pwd } );

		// cookie.email = rc.email;
		cfcookie(
			name         = "email",
			value        = "#rc.email#",
			expires      = "15",
			preservecase = true
		);

		if ( access.getStatus() ) {
			super.setAuthUser( access.getAccount() );

			Location( "/manager/dashboard", false );
		} else {
			setMessage( "Login e/o password errate.", "warning" );

			// TODO: Report Ortus:
			// - only with "/manager/login" it location to "index.cfm?/manager/login"
			// - with "uri" work fine, but raise an exception. Work adding "postProcessExempt=false"
			relocate(
				uri               = "/manager/login",
				postProcessExempt = false,
				addToken          = false
			);
		}

		rc.email = StructKeyExists( cfcookie, "email" ) ? cfcookie.email : "";

		relocate(
			uri               = "/manager/login",
			postProcessExempt = false,
			addToken          = false
		);
	}

	function logout( event, rc, prc ){
		super.logout();

		setMessage( "Ti sei disconnesso.", "success" );
		relocate(
			uri               = "/manager/login",
			postProcessExempt = false,
			addToken          = false
		);
	}

	// security: AUTHENTICATED
	function changeUser( event, rc, prc ){
		var result = super.changeUser( rc.id );

		if ( result ) {
			setMessage( "Hai modificato il tuo utente.", "success" );
		} else {
			setMessage( "Non puoi accedere a questo utente.", "warning" );
		}

		relocate(
			uri               = "/manager/dashboard",
			postProcessExempt = false,
			addToken          = false
		);
	}

}
