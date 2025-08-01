component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title    = "Prodotti base";
		prc.statuses = super.fire( "status.list", [ "PRODUCT" ] );

		prc.jsScripts.add( "app-fruit-list" );

		prc.page[ "statuses" ] = prc.statuses;
		prc.page[ "lines" ]    = super.fire( "line.list" );

		event.setView( "fruit/list" );
	}

}
