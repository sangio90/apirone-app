component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){

		var memy = super.getMementify();

		prc.title = "Tipi prezzi";

		prc.statuses = super.fire( "status.list", [ "PRICE_TYPE" ] );
		prc.methods  = super.fire( "lookup.list", [ "priceMethod" ] );
		prc.entities = super.fire( "lookup.list", [ "entity" ] );

		prc.page["entities"] = memy.convertList( prc.entities, "list" );
		prc.page["methods"]  = memy.convertList( prc.methods, "list" );
		prc.page["statuses"] = memy.convertList( prc.statuses, "list" );

		prc.jsScripts.add( "app-price-type" );

		event.setView( "price/type/list" );
	}

}
