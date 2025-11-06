component extends="com.apirone.core.controller.AbsController" {

	function get( event, rc, prc ){
		prc.title = "Il mio account";

		prc.jsFiles.add( "app-my" );

		event.setView( "my/account" );
	}

	function settings( event, rc, prc ){
		prc.title = "Le mie preferenze";

		prc.jsFiles.add( "app-my" );

		event.setView( "my/settings" );
	}

}
