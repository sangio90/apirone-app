component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Costi per linea/finitura";

		prc.categories = super.fire( "ProductCategory.list" );
		prc.lines      = super.fire( "Line.list" );
		prc.finishes   = super.fire( "Finish.list" );

		prc.jsFiles.add( "app-line-cost" );

		event.setView( "line/cost/list" );
	}
}
