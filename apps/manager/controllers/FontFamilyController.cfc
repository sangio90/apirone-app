component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Font Family";

		prc.jsScripts.add( "app-font-family" );

		event.setView( "font-family/list" );
	}

}
