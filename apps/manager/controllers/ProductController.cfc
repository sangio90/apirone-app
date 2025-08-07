component extends="com.apirone.core.controller.AbsController" {

	function detail( event, rc, prc ){
		var product = super.fire( "product.get", [ rc.id ] );

		if ( IsNull( product ) ) {
			// TODO: better than this
			event.renderData( data = "<h3>Articolo non trovato</h3>" );
			return;
		}

		prc.product = product;

		prc.size   = product.getSize();
		prc.finish = product.getFinish();
		prc.line   = product.getLine();

		// frutti
		if (
			product
				.getCategory()
				.getMode()
				.getId() == "BAS"
		) {
			prc.title    = product.getName();
			prc.subtitle = product.getCategory().getName();
			prc.textLink = "Componenti per #product.getCategory().getName()# / #product.getName()#";
		} else {
			prc.title    = "Finitura #product.getFinish().getName()#, dimensione #product.getSize().getCode()#";
			prc.subtitle = "#product.getCategory().getName()#, Linea #product.getLine().getName()#";
			prc.textLink = "Componenti per #product.getLine().getName()# / #product.getSize().getCode()# / #product.getFinish().getName()#";

			prc.sizes      = super.fire( "size.list", { lineId = prc.line.getId() } );
			prc.statusList = super.fire( "status.list", [ "line" ] );
			prc.finishes   = super.fire( "finish.list", { lineId = prc.line.getId() } );

			prc.page[ "lineId" ]   = prc.line.getId();
			prc.page[ "products" ] = super.fire( "product.list", { lineId = prc.line.getId() } );
		}

		prc.jsScripts.add( "app-component" );
		prc.jsScripts.add( "app-attribute-detail" );
		prc.jsScripts.add( "app-product-items" );


		prc.page[ "productId" ]           = product.getId();
		prc.page[ "attributeStatusList" ] = super.fire( "status.list", [ "attribute" ] );

		prc.page[ "categories" ] = super.getCategoriesAsJSON();

		event.setView( "product/detail" );
	}

	function items( event, rc, prc ){
		var data   = [];
		var result = super.getResult();

		var items = super.fire( "ProductItemProduct.calculate", { productId = rc.id } );

		event.setView( "product/items" );
	}


	function listByCategoryId( event, rc, prc ){
		// TODO: not used, remove?
		getLogger().debug( "ProductController.listByCategoryId: someone use this method? CategoryId: #rc.id#" );

		param rc.id = "";

		var category = super.fire( "productCategory.get", [ rc.id ] );

		prc.title    = category.getName();
		prc.statuses = super.fire( "status.list", [ "PRODUCT" ] );

		// prc.jsScripts.add( "app-component" );
		// prc.jsScripts.add( "app-attribute-detail" );
		prc.jsScripts.add( "app-product-detail" );
		prc.jsScripts.add( "app-product-list" );
		// prc.jsScripts.add( "app-product-detail" );

		prc.page[ "statuses" ] = prc.statuses;

		event.setView( "product/list" );
	}

	function combinations( event, rc, prc ){
		param rc.id = "";

		prc.statuses            = super.fire( "status.list", [ "PRODUCT" ] );
		var product             = super.service( "Product" ).get( rc.id );
		prc.title               = "Combinazioni #product.getSize().getCode()#, finitura #product.getFinish().getName()#";
		prc.subtitle            = "Linea #product.getLine().getName()#";
		prc.page[ "productId" ] = product.getId();

		prc.jsScripts.add( "app-product-combinations" );
		prc.page[ "statuses" ] = prc.statuses;
		event.setView( "product/combinations" );
	}


	/*
		private methods
	*/

	private Array function convertTree( required Array items ){
		var result = [];

		for ( thisItem in items ) {
			var row = super.getDataMapper().convert( thisItem, "ProductItemTree", true );

			if ( !IsNull( thisItem?.getChildren() ) ) {
				row[ "children" ] = convertTree( items = thisItem.getChildren() );
			}

			ArrayAppend( result, row );
		}

		return result;
	}

}
