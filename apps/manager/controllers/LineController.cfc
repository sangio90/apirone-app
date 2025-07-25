component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
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

	function listByCategoryId( event, rc, prc ){
		if ( !rc.keyExists( "categoryId" ) ) {
			// move to most used category: plates
			cflocation( url = "/manager/lines/categories/22", addToken = "false" );

			abort;
		}

		prc.category   = super.fire( "ProductCategory.get", [ rc.categoryId ] );
		prc.categories = super.fire( "ProductCategory.list" );

		prc.title = "Linee per < #prc.category.getName()# >";

		prc.statuses       = super.fire( "status.list", [ "LINE" ] );
		// prc.thicknesses    = super.fire( "lookup.list", [ "thickness" ] );
		prc.lineCategories = super.fire( "ProductCategory.list" );

		prc.jsScripts.add( "app-line-category" );

		prc.page[ "statuses" ]   = prc.statuses;
		prc.page[ "categoryId" ] = prc.category.getId();

		event.setView( "line/list-category" );
	}


	function attributes( event, rc, prc ){
		var products = super.fire( "product.list", { lineId = rc.id } );

		if ( products.len() ) {
			cflocation( url = "/manager/products/#products[ 1 ].getId()#", addToken = false );
		} else {
			setMessage( type = "warning", message = "Carica almeno un prodotto" );

			// TODO: show message
			cflocation( url = "/manager/lines/#rc.id#/products?msg=first-load-products", addToken = false );
		}
	}

	function products( event, rc, prc ){
		prc.existingProducts = [];

		prc.line     = super.fire( "line.get", [ rc.id ] );
		prc.category = super.fire( "productCategory.get", [ rc.categoryId ] );

		prc.page[ "line" ] = prc.line;

		prc.title = "Combinazioni per < #prc.category.getName()# linea #prc.line.getName()# >";

		prc.sizes    = super.fire( "size.list", { categoryId = prc.category.getId() } );
		prc.finishes = super.fire( "finish.list", { categoryId = prc.category.getId() } );

		var productsList = super.fire( "product.list", { lineId = rc.id } );

		for ( var product in productsList ) {
			prc.existingProducts.add( "#product.getSize().getId()#__#product.getFinish().getId()#" );
		}

		prc.jsScripts.add( "app-line" );

		event.setView( "line/products" );
	}

}
