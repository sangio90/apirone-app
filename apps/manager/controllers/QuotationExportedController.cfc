component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Preventivi Esportati";

		prc.jsFiles.add( "app-quotation-exported" );

		event.setView( "quotation-exported/list" );
	}

}
