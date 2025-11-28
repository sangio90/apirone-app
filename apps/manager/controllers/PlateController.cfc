component extends="com.apirone.core.controller.AbsController" {

	function list(
		event,
		rc,
		prc
	){
		prc.title = "Placche";

		prc.jsFiles.add( "app-plate" );

		event.setView( "plate/list" );
	}

	function edit(
		event,
		rc,
		prc
	){
		prc.obj = super.fire( "line.get", [ rc.id ] );

		prc.title = "Modifica linea < #prc.obj.getName()# >";

		prc.models       = super.fire( "model.list" );
		prc.thicknesses = super.fire( "lookup.list", [ "thickness" ] );

		prc.jsFiles.add( "app-line-detail" );

		event.setView( "line/detail" );
	}

	function designer(
		event,
		rc,
		prc
	){
		prc.title = "Designer placche";

		prc.jsFiles.add("stan/app-plate");
		prc.cssFiles.add("stan-plate");

		event.setView( "plate/designer" );
	}

	function map(
		event,
		rc,
		prc
	){
		prc.title = "Mappa placche";

		prc.jsFiles.add("stan/app-plate");
		prc.cssFiles.add("stan/app-plate");

		event.setView( "plate/map" );
	}

}
