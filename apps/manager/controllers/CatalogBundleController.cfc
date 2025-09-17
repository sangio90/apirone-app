component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Bundles catalogo";

		prc.jsScripts.add( "app-catalog-bundle" );

		event.setView( "catalog-bundle/list" );
	}

}
