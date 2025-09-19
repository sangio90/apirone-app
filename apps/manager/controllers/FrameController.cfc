component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Armature";

		prc.statuses = super.fire( "status.list", [ "LINE" ] );

		prc.page[ "statuses" ] = super.getMementify().convertList( prc.statuses );

		prc.jsScripts.add( "app-frame" );

		event.setView( "frame/list" );
	}

}
