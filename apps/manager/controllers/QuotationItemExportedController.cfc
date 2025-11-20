component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Prodotti Preventivi Esportati";

		prc.jsFiles.add( "app-quotation-item-exported" );

		event.setView( "quotation-item-exported/list" );
	}

}
