component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Tempi di produzione";

		var mm = super.getMementify();

		prc.jsFiles.add( "app-production-time" );

		prc.page[ "statuses" ] = mm.convertList( super.fire( "status.list", [ "PRODUCTION_TIME" ] ) );

		event.setView( "production-time/list" );
	}

}
