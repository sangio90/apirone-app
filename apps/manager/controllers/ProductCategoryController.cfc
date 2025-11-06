component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Categorie prodotti";

		prc.types    = super.fire( "productCategoryType.list" );
		prc.statuses = super.fire( "status.list", [ "PRODUCT_CATEGORY" ] );
		prc.modes    = super.fire( "lookup.list", [ "productCategoryMode" ] );

		prc.page[ "types" ]    = prc.types;
		prc.page[ "statuses" ] = prc.statuses;
		prc.page[ "modes" ]    = prc.modes;

		prc.jsFiles.add( "app-product-category" );

		event.setView( "product-category/list" );
	}

}
