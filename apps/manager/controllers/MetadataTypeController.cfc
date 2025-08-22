component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Metadata";
		var mm    = super.getMementify();

		prc.statuses  = super.fire( "status.list", [ "METADATA_TYPE" ] );
		prc.dataTypes = super.fire( "lookup.list", [ "dataType" ] );
		prc.units     = super.fire( "lookup.list", [ "measurementUnit" ] );
		prc.entities  = super.fire( "lookup.list", [ "entity" ] );

		prc.jsScripts.add( "app-metadata-type-detail" );
		prc.jsScripts.add( "app-metadata-type-list" );

		prc.page[ "statuses" ]  = mm.convertList( prc.statuses, "list" );
		prc.page[ "units" ]     = mm.convertList( prc.units, "list" );
		prc.page[ "dataTypes" ] = mm.convertList( prc.dataTypes, "list" );
		prc.page[ "entities" ]  = mm.convertList( prc.entities, "list" );

		event.setView( "metadata-type/list" );
	}

}
