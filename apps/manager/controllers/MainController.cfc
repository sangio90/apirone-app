component extends="com.apirone.core.controller.AbsController" {

	function dashboard( event, rc, prc ){
		prc.title = "Dashboard";

		event.setView( "main/dashboard" );
	}

	function selects( event, rc, prc ){
		prc.title = "Dashboard";

		event.setView( "util/selects" );
	}

}
