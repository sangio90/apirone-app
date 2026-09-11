component output="true" accessors="true" {

	property name="keys" type="Struct";

	public Configuration function init(){
		var settings = new config.Settings();

		var keys = {
			"appName"    = settings.get( "app.name" ),
			"appVersion" = settings.get( "app.version" ),
			"owner"      = {
				"name"  = settings.get( "owner.name" ),
				"vat"   = settings.get( "owner.vat" ),
				"email" = settings.get( "owner.email" )
			},
			"font" = {
				"directory" = { "prefix" = settings.get( "font.prefix" ) }
			},
			"filesHost"    = "#settings.get( "files.host" )#",
			// griglia incisioni frutti: codici degli attributi "radice" dell'incisione, in ordine
			// di priorità risalendo l'albero (superiore, inferiore, logo)
			"engravingRootAttributeCodes" = [ "IS", "II", "IL" ],
			// attributi che portano il simbolo inciso (il valore che si posiziona sulla griglia)
			"engravingSymbolAttributeCodes" = [ "SM" ],
			// lato del riquadro del simbolo inciso, in mm: usato per disegnarlo in scala
			// sull'anteprima della placca e nelle stampe
			"engravingSymbolSizeMm" = 10,
			"imagesConfig" = {
				"productItem" = {
					"path"  = "product-items",
					"types" = {
						"horizontal" = { "sizes" = [ { "width" = "500" } ] },
						"vertical"   = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"product" = {
					"path"  = "products",
					"types" = {
						"horizontal" = { "sizes" = [ { "width" = "500" } ] },
						"vertical"   = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"combination" = {
					"path"  = "combinations",
					"types" = {
						"horizontal" = { "sizes" = [ { "width" = "500" } ] },
						"vertical"   = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"combinationItem" = {
					"path"  = "combination-items",
					"types" = {
						"horizontal" = { "sizes" = [ { "width" = "500" } ] },
						"vertical"   = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"attributeValue" = {
					"path"  = "attribute-values",
					"types" = {
						"horizontal" = { "sizes" = [ { "width" = "500" } ] },
						"vertical"   = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"quotationItem" = {
					"path"  = "quotation-items",
					"types" = {
						"default" = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"quotationZone" = {
					"path"  = "quotation-zones",
					"types" = {
						"default" = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"pictogram" = {
					"path"  = "pictograms",
					"types" = {
						"default" = { "sizes" = [] }
					}
				},
				"quotationStatusHistory" = {
					"path"  = "quotation-status-history",
					"types" = {
						"default" = { "sizes" = [ { "width" = "500" } ] }
					}
				},
			},
			"encryptKey" = settings.get( "db.encryptKey" )
		};

		setKeys( keys );

		return this;
	}

	public Any function get( required String path = "" ){
		if ( Len( arguments.path ) ) {
			var keys = getkeys();

			return StructGet( "keys.#arguments.path#" );
		}

		return getKeys();
	}

}
