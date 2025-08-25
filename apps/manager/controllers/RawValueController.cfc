component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Valori base";

		prc.page[ "statusList" ] = super.fire( "status.list", [ "RAW_VALUE" ] );

		prc.jsScripts.add( "app-metadata" );
		prc.jsScripts.add( "app-raw-value" );

		event.setView( "raw-value/list" );
	}

}
