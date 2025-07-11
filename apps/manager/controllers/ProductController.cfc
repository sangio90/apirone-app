component extends="com.apirone.core.controller.AbsController" {

	function detail(
		event,
		rc,
		prc
	){
		var product = super.fire( "product.get", [ rc.id ] );

		// dump(DESerializeJSON(SerializeJSON(product.getSize())));
		// abort;

		prc.size   = product.getSize();
		prc.finish = product.getFinish();
		prc.line   = product.getLine();

		prc.title    = "Dimensione #product.getSize().getCode()#, finitura #product.getFinish().getName()#";
		prc.subtitle = "Linea #product.getLine().getName()#";

		prc.sizes = super.fire( "size.list", { lineId = prc.line.getId() } );

		/*
        for( var s in prc.sizes  ) {
            dump( s.getId() )
            dump( s.getCode() )
        }
        abort;
        */

		prc.statusList = super.fire( "status.list", [ "line" ] );
		prc.finishes   = super.fire( "finish.list", { lineId = prc.line.getId() } );

		var products = super.fire( "product.list", { lineId = prc.line.getId() } );

		prc.jsScripts.add( "app-component" );
		prc.jsScripts.add( "app-attribute-detail" );

		prc.jsScripts.add( "app-product" );

		prc.page[ "lineId" ] = prc.line.getId();

		prc.page[ "productId" ]           = product.getId();
		prc.page[ "products" ]            = products;
		prc.page[ "attributeStatusList" ] = super.fire( "status.list", [ "attribute" ] );

		prc.page[ "categories" ] = super.getCategoriesAsJSON();

		event.setView( "product/detail" );
	}

	function items(
		event,
		rc,
		prc
	){
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

	function listByCategoryId(
		event,
		rc,
		prc
	){
		param prc.id = "";

		var category = super.fire( "productCategory.get", [ prc.id ] );

		prc.title    = category.getName();
		prc.statuses = super.fire( "status.list", [ "PRODUCT" ] );

		prc.jsScripts.add( "app-product" );

		prc.page[ "statuses" ] = prc.statuses;

		event.setView( "product/list" );
	}

	private Array function convertTree( required Array items ){
		var result = [];

		for ( thisItem in items ) {
			var row = super.getDataMapper().convert( thisItem, "ProductItemTree", true );

			if ( !isNull( thisItem?.getChildren() ) ) {
				row[ "children" ] = convertTree( items = thisItem.getChildren() );
			}

			arrayAppend( result, row );
		}

		return result;
	}

}
