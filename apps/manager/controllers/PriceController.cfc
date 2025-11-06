component extends="com.apirone.core.controller.AbsController" {

	function manage( event, rc, prc ){

		prc.categories = super.fire( "productCategory.list", { modeId = "COM" } );
		prc.lines      = super.fire( "line.list" );
		prc.models     = super.fire( "model.list" );
		prc.statuses   = super.fire( "status.list", [ "line" ] );
		prc.finishes   = super.fire( "finish.list" );
		prc.methods    = super.fire( "lookup.list", [ "priceMethod" ] );
		prc.types      = super.fire( "priceType.list" );

		prc.title = "Gestione prezzi";

		prc.jsFiles.add( "app-price-manage" );

		event.setView( "price/manage" );
	}

}
