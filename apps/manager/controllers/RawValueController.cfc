component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Valori base";

		prc.page[ "statusList" ] = super.fire( "status.list", [ "RAW_VALUE" ] );

		prc.jsFiles.add( "app-metadata" );
		prc.jsFiles.add( "app-raw-value" );

		event.setView( "raw-value/list" );
	}

}
