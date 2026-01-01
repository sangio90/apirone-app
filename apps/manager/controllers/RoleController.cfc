component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Lista dei ruoli";

		var memy = super.getMementify();

		//prc.page["roles"] = DeserializeJSON( FileRead( "/config/data/roles.json.cfm" ) );
		//prc.page["entities"] = DeserializeJSON( FileRead( "/config/data/entities.json.cfm" ) );

		prc.page["entities"] = memy.convertList( super.fire( "lookup.list", ["ENTITY"] ) );

		prc.page["roles"] = memy.convertList( super.fire( "role.list" ) );

		prc.jsFiles.add( "app-role" );

		event.setView( "role/list" );
	}

}
