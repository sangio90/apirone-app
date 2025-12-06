component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Servizi";

		var memy = super.getMementify();

		prc.statuses   = super.fire( "status.list", [ "ARTICLE" ] );
		prc.types = super.fire( "lookup.list", ["articleType"] );

		prc.page[ "statuses" ]   = prc.statuses;
		prc.page[ "types" ] = memy.convertList( prc.types );

		prc.jsFiles.add( "app-article" );

		event.setView( "article/list" );
	}

}
