component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Prodotti base";

		var memy = super.getMementify();

		prc.statuses   = super.fire( "status.list", [ "PRODUCT" ] );
		prc.categories = super.fire( "ProductCategory.list", { modeId = "BAS" } );

		prc.page[ "statuses" ]   = prc.statuses;
		prc.page[ "lines" ]      = super.fire( "line.list" );
		prc.page[ "categories" ] = memy.convertList( prc.categories );
		prc.page[ "methods" ]    = memy.convertList( super.fire( "lookup.list", { "entity" = "priceMethod" } ) );

		prc.jsFiles.add( "app-price" );
		prc.jsFiles.add( "app-fruit-list" );

		event.setView( "fruit/list" );
	}

}
