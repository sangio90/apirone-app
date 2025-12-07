component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Servizi";

		var memy = super.getMementify();

		prc.types = super.fire( "lookup.list", ["articleType"] );
		prc.statuses   = super.fire( "status.list", [ "ARTICLE" ] );

		prc.page[ "types" ] = memy.convertList( prc.types );
		prc.page[ "statuses" ]   = memy.convertList( prc.statuses );

		prc.jsFiles.add( "app-article" );

		event.setView( "article/list" );
	}

}
