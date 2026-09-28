component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Costi per linea/modello";

		prc.page['categories']   = super.fire( "ProductCategory.list" );
		// Linee e modelli ridotti a id/nome: le select a cascata filtrano sulle combinazioni
		// di catalogo, il resto del bean non serve e appesantirebbe AP.page
		prc.page['lines']        = super.fire( "Line.list" ).map( function( line ){
			return { "id" = line.getId(), "name" = line.getName() };
		} );
		prc.page['models']       = super.fire( "Model.list" ).map( function( model ){
			return { "id" = model.getId(), "name" = model.getName() };
		} );
		prc.page['combinations'] = super.fire( "LineModelCost.listCombinations" );

		prc.jsFiles.add( "app-line-model-cost" );

		event.setView( "line/model-cost/list" );
	}
}
