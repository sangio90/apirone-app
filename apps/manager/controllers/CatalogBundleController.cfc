component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Bundles catalogo";

		prc.lines      = super.fire( "line.list" );
		prc.models     = super.fire( "model.list" );
		prc.categories = super.fire( "productCategory.list" );

		prc.jsScripts.add( "app-catalog-bundle" );

		event.setView( "catalog-bundle/list" );
	}

}
