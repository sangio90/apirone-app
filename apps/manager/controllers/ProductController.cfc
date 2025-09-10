component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		// var params[ "categoryModeId" ] = "COM";

		prc.categories = super.fire( "productCategory.list", { modeId = "COM" } );
		prc.lines      = super.fire( "line.list" );
		prc.models     = super.fire( "model.list" );
		prc.statuses   = super.fire( "status.list", [ "line" ] );
		prc.finishes   = super.fire( "finish.list" );

		prc.title = "Prodotti complessi";

		prc.jsScripts.add( "app-product-list" );

		event.setView( "product/list" );
	}

	function detail( event, rc, prc ){
		var product = super.fire( "product.get", [ rc.id ] );

		if ( IsNull( product ) ) {
			// TODO: better than this
			event.renderData( data = "<h3>Articolo non trovato</h3>" );
			return;
		}

		prc.product = product;

		prc.model  = product.getModel();
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
			prc.title    = "Finitura #product.getFinish().getName()#, modello #product.getModel().getCode()#";
			prc.subtitle = "Categoria #product.getCategory().getName()#, linea #product.getLine().getName()#";
			prc.textLink = "Componenti per #product.getLine().getName()# / #product.getModel().getCode()# / #product.getFinish().getName()#";

			prc.models     = super.fire( "model.list", { lineId = prc.line.getId() } );
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
		/*
		getLogger().debug( "ProductController.listByCategoryId: someone use this method? CategoryId: #rc.id#" );

		param rc.id = "";

		var category = super.fire( "productCategory.get", [ rc.id ] );

		prc.title    = category.getName();
		prc.statuses = super.fire( "status.list", [ "PRODUCT" ] );

		prc.jsScripts.add( "app-product-detail" );
		prc.jsScripts.add( "app-product-list" ); // remove this file

		prc.page[ "statuses" ] = prc.statuses;

		event.setView( "product/list" );
		*/
	}

	function combinations( event, rc, prc ){
		param rc.id = "";

		prc.statuses            = super.fire( "status.list", [ "PRODUCT" ] );
		var product             = super.service( "Product" ).get( rc.id );
		prc.title               = "Combinazioni #product.getModel().getCode()#, finitura #product.getFinish().getName()#";
		prc.subtitle            = "Linea #product.getLine().getName()#";
		prc.page[ "productId" ] = product.getId();

		prc.jsScripts.add( "app-product-combinations" );
		prc.page[ "statuses" ] = prc.statuses;
		event.setView( "product/combinations" );
	}

	function print( event, rc, prc ){
		prc.title       = "Distinte basi";
		param rc.report = "bill-of-material";

		var params = {
			lineId     = Len( rc.lineId ) ? rc.lineId : NullValue(),
			modelId    = Len( rc.modelId ) ? rc.modelId : NullValue(),
			categoryId = Len( rc.categoryId ) ? rc.categoryId : NullValue(),
			statusId   = Len( rc.statusId ) ? rc.statusId : NullValue()
		};

		var result = super.fire( "product.search", params );

		var filename = ExpandPath("/../repository/private/_tmp/#rc.report#_#DateTimeFormat(now(), 'yyyyMMddHHnnss')#.pdf");

		var data = {
			params  = { "orientation" = "portrait", "fontembed" = true },
			title   = "Distinte basi",
			rows    = super.getMementify().convertList( result.getData(), "list" ),
			filename = filename,
			columns = [
				{ title = "ID" },
				{ title = "Linea" },
				{ title = "Modello" },
				{ title = "Finitura" }
			]
		}

		var pdfArgs = { bookmark = "yes", backgroundVisible = "yes", orientation="landscape" };

		// var bean = super.bean( "PrintList" );
		// var reportData = bean.getRawMemento();

		//prc.printData = data;

		event.renderData( 
			data=renderView(
				view="report/template/#rc.report#", 
				args=data
			), 
			type="PDF" 
		);

		//var binary = FileReadBinary( filename );
        //event.renderData(data=binary,type="PDF");

		//event.setView( "report/template/#rc.report#" ).setLayout( "print" );
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
