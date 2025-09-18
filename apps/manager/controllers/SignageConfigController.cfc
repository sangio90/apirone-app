component extends="com.apirone.core.controller.AbsController" {

	function rowConfig( event, rc, prc ){
		param rc.id = "";

		var memy = super.getMementify();

		var catalogBundleId = "";
		var selectedFonts   = [];

		if ( !Len( rc.id ) ) {
			catalogBundleId = super.service( "CatalogBundle" ).findId( argumentCollection = rc );

			if ( !IsNull( catalogBundleId ) ) {
				cflocation( url = "/manager/signages/rows-config/#catalogBundleId#", addToken = "false" );
				return;
			};

			prc.line     = super.fire( "line.get", [ rc.lineId ] );
			prc.model    = super.fire( "model.get", [ rc.modelId ] );
			prc.category = super.fire( "productCategory.get", [ rc.categoryId ] );
		} else {
			var catalogBundle = super.fire( "catalogBundle.get", [ rc.id ] );

			prc.line     = catalogBundle.getLine();
			prc.model    = catalogBundle.getModel();
			prc.category = catalogBundle.getCategory();

			/*
				selected fonts
			*/
			var fonts = super.fire( "signageConfig.list", { "catalogBundleId" = catalogBundle.getId() } );

			for ( var item in fonts ) {
				// var obj = getDataMapper().convert( item, "signageConfig", true );
				var obj = memy.convert( item, "list" );
				selectedFonts.add( obj );
			}
		}

		prc.title    = "Configurazione per la linea < #prc.line.getName()#, #prc.model.getName()# >";
		prc.subtitle = "#prc.category.getName()#";


		/*
			all fonts
		*/
		var availableFonts = [];
		var fonts          = super.fire( "font.list" );

		for ( var item in fonts ) {
			// var obj = getDataMapper().convert( item, "Font", true );
			var obj = memy.convert( item, "list" );
			availableFonts.add( obj );
		}

		prc.page[ "availableFonts" ] = availableFonts;
		prc.page[ "selectedFonts" ]  = selectedFonts;

		prc.page[ "catalogBundle" ] = {
			"id"         = catalogBundleId,
			"lineId"     = prc.line.getId(),
			"modelId"    = prc.model.getId(),
			"categoryId" = prc.category.getId()
		};

		prc.jsScripts.add( "app-signage-config" );

		event.setView( "signage/signage-config" );
	}

	function list( event, rc, prc ){
	}

}
