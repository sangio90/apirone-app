component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){

		prc.title = "Setting generali";
		var mm    = super.getMementify();

		prc.statuses  = super.fire( "status.list", [ "METADATA_TYPE" ] );

		//prc.jsFiles.add( "app-global-metadata-detail" );
		prc.jsFiles.add( "app-global-metadata-list" );

		prc.page[ "statuses" ]  = mm.convertList( prc.statuses, "list" );

		event.setView( "global-metadata/list" );
	}

}
