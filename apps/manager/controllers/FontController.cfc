component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Font";

		prc.jsScripts.add( "app-font" );

		event.setView( "font/list" );
	}

}
