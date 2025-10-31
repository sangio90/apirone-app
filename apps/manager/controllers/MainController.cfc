component extends="com.apirone.core.controller.AbsController" {

	function dashboard( event, rc, prc ){
		prc.title = "Dashboard";

		event.setView( "main/dashboard" );
	}

	function tmp( event, rc, prc ){
		prc.title = "Tmp";

		dump( prc );
		abort;

		event.setView( "util/tmp" );
	}

}
