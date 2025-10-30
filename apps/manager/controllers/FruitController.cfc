component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Prodotti base";

		prc.statuses   = super.fire( "status.list", [ "PRODUCT" ] );
		prc.categories = super.fire( "ProductCategory.list", { modeId = "BAS" } );

		prc.page[ "statuses" ]   = prc.statuses;
		prc.page[ "lines" ]      = super.fire( "line.list" );
		prc.page[ "categories" ] = super.getMementify().convertList( prc.categories );

		prc.jsScripts.add( "app-fruit-list" );

		event.setView( "fruit/list" );
	}

}
