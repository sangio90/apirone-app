component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Lista degli utenti";

		prc.roles    = super.fire( "role.list" );
		prc.statuses = super.fire( "status.list", [ "ACCOUNT" ] );
		prc.langs    = super.fire( "lang.list" );

		prc.page[ "roles" ]    = prc.roles;
		prc.page[ "statuses" ] = prc.statuses;
		prc.page[ "langs" ]    = prc.langs;

		prc.jsFiles.add( "app-user" );

		event.setView( "user/list" );
	}

}