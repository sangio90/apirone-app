component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Font Family";
		prc.pictogramCodes = super.fire( "lookup.list", { entity = "pictogramCode" } );
		prc.page[ "pictogramCodes" ] = super.getMementify().convertList( prc.pictogramCodes );

		prc.jsFiles.add( "app-font-family" );

		event.setView( "font-family/list" );
	}

}
