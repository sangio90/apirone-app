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
			flash.put( "message", "Login e/o password errate." );

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

	function changeRole( event, rc, prc ){
		var result = super.changeRole( rc.id );

		if ( result ) {
			setMessage( "Hai modificato il tuo ruolo.", "success" );
		} else {
			setMessage( "Non puoi accedere a questo ruolo.", "warning" );
		}

		relocate(
			uri               = "/manager/dashboard",
			postProcessExempt = false,
			addToken          = false
		);
	}

	function logout( event, rc, prc ){
		super.logout();

		flash.put( "message", "Ti sei disconnesso." );

		Location( "/manager/login?msg=disconnected", false );
	}

}
