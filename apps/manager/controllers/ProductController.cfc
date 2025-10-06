component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		// var params[ "categoryModeId" ] = "COM";

		var memy = super.getMementify();

		prc.categories = super.fire( "productCategory.list", { modeId = "COM" } );
		prc.lines      = super.fire( "line.list" );
		prc.models     = super.fire( "model.list" );
		prc.statuses   = super.fire( "status.list", [ "line" ] );
		prc.finishes   = super.fire( "finish.list" );

		prc.title = "Prodotti complessi";

		prc.jsScripts.add( "app-product-list" );
		prc.jsScripts.add( "app-price" );

		prc.page[ "methods" ] = memy.convertList( super.fire( "lookup.list", { "entity" = "priceMethod" } ) );

		event.setView( "product/list" );
	}

	function detail( event, rc, prc ){
		var product = super.fire( "product.get", [ rc.id ] );
		var memy    = super.getMementify();

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
			prc.page[ "products" ] = memy.convertList(
				super.fire( "product.list", { lineId = prc.line.getId() } )
			);
		}

		prc.page[ "productId" ]           = product.getId();
		prc.page[ "attributeStatusList" ] = memy.convertList( super.fire( "status.list", [ "attribute" ] ) );
		prc.page[ "methods" ] = memy.convertList( super.fire( "lookup.list", { "entity" = "priceMethod" } ) );

		prc.page[ "categories" ] = super.getCategoriesAsJSON();

		prc.jsScripts.add( "app-file" );
		prc.jsScripts.add( "app-price" );
		prc.jsScripts.add( "app-component-modal" );
		prc.jsScripts.add( "app-attribute-detail" );
		prc.jsScripts.add( "app-product-items" );

		event.setView( "product/detail" );
	}

	function items( event, rc, prc ){
		var data   = [];
		var result = super.getResult();

		var items = super.fire( "ProductItemProduct.calculate", { productId = rc.id } );

		event.setView( "product/items" );
	}


	function combinations( event, rc, prc ){
		param rc.id = "";

		var product  = super.service( "Product" ).get( rc.id );
		prc.statuses = super.fire( "status.list", [ "PRODUCT" ] );

		// prc.title = "Combinazioni #product.getModel().getCode()#, finitura #product.getFinish().getName()#";
		// TODO: migliorare titolo per base/complesso
		prc.title    = "Combinazioni";
		prc.subtitle = "Linea -";

		prc.jsScripts.add( "app-file" );
		prc.jsScripts.add( "app-product-combinations" );

		prc.page[ "statuses" ]  = prc.statuses;
		prc.page[ "productId" ] = product.getId();

		event.setView( "product/combinations" );
	}

	function print( event, rc, prc ){
		param rc.report = "bill-of-material";

		prc.title = "Distinte basi";

		var memy = super.getMementify();

		var searchArgs = {};
		var filters    = {};

		if ( Len( rc.lineId ) ) {
			var line = super.service( "line" ).get( rc.lineId );

			searchArgs.lineId  = rc.lineId;
			filters[ "Linea" ] = line.getName();
		}

		if ( Len( rc.categoryId ) ) {
			var category = super.service( "productCategory" ).get( rc.categoryId )

			searchArgs.lineId      = rc.lineId;
			filters[ "Categoria" ] = category.getName();
		}

		if ( Len( rc.modelId ) ) {
			var model = super.service( "model" ).get( rc.modelId )

			searchArgs.modelId   = rc.modelId;
			filters[ "Modello" ] = model.getName();
		}

		if ( Len( rc.statusId ) ) {
			var status = super.service( "status" ).get( rc.statusId )

			searchArgs.statusId = rc.statusId;
			filters[ "Status" ] = status.getName();
		}


		var products = super.fire( "product.list", searchArgs );

		var data = {};

		data.products = [];

		var blundlesCreated = {};

		for ( var product in products ) {
			var row = {}

			row.line   = memy.convert( product.getLine() );
			row.model  = memy.convert( product.getModel() );
			row.finish = memy.convert( product.getFinish() );

			row.bundle = {};

			if ( !blundlesCreated.keyExists( "#lineId#__#modelId#" ) ) {
				row[ "bundle" ][ "#lineId#__#modelId#" ] = memy.convertList(
					service( "component" ).list( lineId = lineId, modelId = modelId )
				);

				blundlesCreated[ "#lineId#__#modelId#" ] = true;
			}

			var components = service( "component" ).list( productId = product.getId() );

			row[ "components" ] = memy.convertList( components, "list" );

			row[ "title" ] = "#product.getCategory().getName()# - #product.getLine().getName()# - #product.getModel().getName()# (#product.getModel().getCode()#) - #product.getFinish().getName()#"

			var productItems = service( "ProductItem" ).getFlatTree(
				productId            = product.getId(),
				includeMissingValues = false
			);

			var items = [];

			for ( var productItem in productItems ) {
				var item = {};

				item = memy.convert( productItem, "list" );

				var itemComponents = service( "component" ).list(
					productItemId                  = productItem.getId(),
					includeBaseAttributeComponents = true
				);

				item[ "components" ] = memy.convertList( itemComponents, "list" );

				items.add( item )
			}

			row[ "productItems" ] = items;

			data.products.add( row );
		}

		var params = {
			title   = "Distinte basi",
			filters = filters,
			data    = data,
			pdfArgs = {
				bookmark          = true,
				backgroundVisible = true,
				orientation       = "landscape",
				pageType          = "A4",
				overwrite         = true,
				fontEmbed         = true,
				saveAsName        = "#rc.report#_#DateTimeFormat( Now(), "yyyyMMdd-HHnnss" )#.pdf"
			}
		}

		event.renderData( data = renderView( view = "report/template/#rc.report#", args = params ), type = "PDF" );
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
