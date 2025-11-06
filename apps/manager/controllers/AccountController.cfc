component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Lista degli account";

		prc.roles    = super.fire( "role.list" );
		prc.statuses = super.fire( "status.list", [ "ACCOUNT" ] );
		prc.langs    = super.fire( "lang.list" );

		prc.page[ "roles" ]    = prc.roles;
		prc.page[ "statuses" ] = prc.statuses;
		prc.page[ "langs" ]    = prc.langs;

		prc.jsFiles.add( "app-account" );

		event.setView( "account/list" );
	}

	function print( event, rc, prc ){
		var user = prc.user;

		var result = getAccessManager().exec( user, "Account.search" );

		prc.printArgs = {
			data   = DeserializeJSON( SerializeJSON( result.getData() ) ),
			fields = "email,role"
		}

		event.setView( "util/print" ).setLayout( "print" );
	}

}