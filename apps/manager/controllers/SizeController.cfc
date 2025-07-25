component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var categories = [];

		prc.title = "Dimensioni e modelli";

		prc.statuses   = super.fire( "status.list", [ "SIZE" ] );
		prc.categories = super.fire( "ProductCategory.list" );
		prc.types      = super.fire( "lookup.list", [ "sizeType" ] );

		for ( var thisCategory in prc.categories ) {
			var row = super.getDataMapper().convert( thisCategory, "ProductCategory", true );
			categories.add( row );
		}

		prc.page[ "categories" ] = categories;
		prc.page[ "statuses" ]   = prc.statuses;
		prc.page[ "types" ]   = prc.types;

		prc.jsScripts.add( "app-size" );

		event.setView( "size/list" );
	}

}
