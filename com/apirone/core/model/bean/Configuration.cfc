component output="true" accessors="true" {

	property name="keys" type="Struct";

	public Configuration function init(){
		var settings = new config.Settings();

		var keys = {
			"appName"    = settings.get( "app.name" ),
			"appVersion" = settings.get( "app.version" ),
			"owner"      = {
				"name"  = settings.get( "owner.namename" ),
				"vat"   = settings.get( "owner.namevat" ),
				"email" = settings.get( "owner.nameemail" )
			},
			"filesHost"    = "#settings.get( "files.host" )#",
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
				}
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
