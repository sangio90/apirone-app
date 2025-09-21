component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Armature";

		prc.statuses = super.fire( "status.list", [ "FRAME" ] );
		prc.orientations = super.fire( "lookup.list", { entity = "orientation" } );

		prc.page[ "statuses" ] = super.getMementify().convertList( prc.statuses );
		prc.page[ "orientations" ] = super.getMementify().convertList( prc.orientations );

		prc.jsScripts.add( "app-frame" );

		event.setView( "frame/list" );
	}

}
