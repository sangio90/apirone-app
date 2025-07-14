component extends="com.apirone.core.controller.AbsController" {

	function detail( event, rc, prc ){
		var product = super.fire( "product.get", [ rc.id ] );

		prc.product = product;

		prc.size   = product.getSize();
		prc.finish = product.getFinish();
		prc.line   = product.getLine();

		if ( product.getCategory().getId() == 22 ) {
			// TODO: set correct title by category
			prc.title    = "Dimensione #product.getSize().getCode()#, finitura #product.getFinish().getName()#";
			prc.subtitle = "Linea #product.getLine().getName()#";

			prc.sizes      = super.fire( "size.list", { lineId = prc.line.getId() } );
			prc.statusList = super.fire( "status.list", [ "line" ] );
			prc.finishes   = super.fire( "finish.list", { lineId = prc.line.getId() } );

			prc.page[ "lineId" ]   = prc.line.getId();
			prc.page[ "products" ] = super.fire( "product.list", { lineId = prc.line.getId() } );
		} else {
			prc.title    = product.getName();
			prc.subtitle = product.getCategory().getName();
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


	/*
    function list( event, rc, prc ){

        prc.title = "Frutti";
        prc.statuses = super.fire( "status.list", ["PRODUCT"] );

        prc.jsScripts.add( "app-fruit-list" );

        prc.page["statuses"] = prc.statuses;

        event.setView("fruit/list");

    }
    */

	function listByCategoryId( event, rc, prc ){
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
