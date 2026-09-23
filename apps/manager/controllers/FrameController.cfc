component extends="com.apirone.core.controller.AbsController" {

	function builder( event, rc, prc ){
		prc.title = "Placche";

		prc.statuses = super.fire( "status.list", [ "FRAME" ] );
		prc.orientations = super.fire( "lookup.list", { entity = "orientation" } );

		prc.page[ "statuses" ] = super.getMementify().convertList( prc.statuses );
		prc.page[ "orientations" ] = super.getMementify().convertList( prc.orientations );

		prc.jsFiles.add( "app-plate-builder" );

		event.setView( "frame/builder" );
	}

}
