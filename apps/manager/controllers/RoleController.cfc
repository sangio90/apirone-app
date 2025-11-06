component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Lista dei Ruoli";

		prc.page['roles'] = DeserializeJSON( FileRead( "/config/data/roles.json.cfm" ) );
		prc.page['entities'] = DeserializeJSON( FileRead( "/config/data/entities.json.cfm" ) );

		prc.jsFiles.add( "app-role" );

		event.setView( "role/list" );
	}

}
