component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Componenti";

		prc.statuses = super.fire( "status.list", [ "ACCOUNT" ] );

		prc.jsFiles.add( "app-component-list" );

		event.setView( "component/list" );
	}

	function reassign( event, rc, prc ){
		prc.title = "Gestione componenti";

		prc.jsFiles.add( "app-component-reassign" );

		event.setView( "component/reassign" );
	}

}
