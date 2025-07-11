component extends="com.apirone.core.controller.AbsController" {

	function list(
		event,
		rc,
		prc
	){
		prc.title = "Linee";

		prc.statuses       = super.fire( "status.list", [ "LINE" ] );
		prc.thicknesses    = super.fire( "lookup.list", [ "thickness" ] );
		prc.lineCategories = super.fire( "ProductCategory.list" );

		prc.jsScripts.add( "app-line" );

		prc.page[ "statuses" ]    = prc.statuses;
		prc.page[ "thicknesses" ] = prc.thicknesses;

		prc.page[ "categories" ] = super.getCategoriesAsJSON();

		event.setView( "line/list" );
	}


	function attributes(
		event,
		rc,
		prc
	){
		var products = super.fire( "product.list", { lineId = rc.id } );

		if ( products.len() ) {
			cflocation( url = "/manager/products/#products[ 1 ].getId()#", addToken = false );
		} else {
			setMessage( type = "warning", message = "Carica almeno un prodotto" );

			// TODO: show message
			cflocation( url = "/manager/lines/#rc.id#/products?msg=first-load-products", addToken = false );
		}
	}


	function products(
		event,
		rc,
		prc
	){
		prc.existingProducts = [];
		prc.line             = super.fire( "line.get", [ rc.id ] );

		prc.page[ "line" ] = prc.line;

		prc.title = "Combinazioni per la linea < #prc.line.getName()# >";

		prc.sizes    = super.fire( "size.list", { categoryId = prc.line.getCategory().getId() } );
		prc.finishes = super.fire( "finish.list", { categoryId = prc.line.getCategory().getId() } );

		var productsList = super.fire( "product.list", { lineId = rc.id } );

		for ( var product in productsList ) {
			prc.existingProducts.add( "#product.getSize().getId()#__#product.getFinish().getId()#" );
		}

		prc.jsScripts.add( "app-line" );

		event.setView( "line/products" );
	}

}
