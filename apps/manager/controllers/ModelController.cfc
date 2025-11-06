component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var categories = [];
		var mm         = super.getMementify();

		prc.title = "Modelli";

		prc.statuses   = super.fire( "status.list", [ "MODEL" ] );
		prc.categories = super.fire( "ProductCategory.list" );
		prc.types      = super.fire( "lookup.list", [ "modelType" ] );

		prc.page[ "types" ]      = mm.convertList( prc.types );
		prc.page[ "statuses" ]   = mm.convertList( prc.statuses );
		prc.page[ "categories" ] = mm.convertList( prc.categories );

		prc.jsFiles.add( "app-model" );

		event.setView( "model/list" );
	}

}
