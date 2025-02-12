component output="true" accessors="true" {
			
	property name="keys" type="Struct";

	public Configuration function init(){

		var settings = new config.Settings();
		
		var keys = {
			"appName"    = settings.get("app.name"),
			"appVersion" = settings.get("app.version"),
			"owner"      = {
				"name"  = settings.get("owner.namename"),
				"vat"   = settings.get("owner.namevat"),
				"email" = settings.get("owner.nameemail")
			},
			"filesHost": "#settings.get("files.host")#",
			"imagesConfig" = {
				"combinationItem" = {
					"dbField" = "combinationItem.id",
					"path" = "combination-items",
					"types" = [
						{
							"id" = "horizontal", //in filetypes.json
							"sizes" = [
								{
									"width" = "200"
								}
							]
						},
						{
							"id" = "vertical", //in filetypes.json
							"sizes" = [
								{
									"width" = "200"
								},
							]
	
						}
					],
				},
				"combination" = {
					"dbField" = "combination.id",
					"path" = "combinations",
					"types" = [
						{
							"id" = "horizontal", //in fileKinds.json
							"sizes" = [
								{
									"width" = "200"
								}
							]
						},
						{
							"id" = "vertical",
							"sizes" = [
								{
									"width" = "200"
								},
							]
	
						}
					],
				},
			},
			"encryptKey": settings.get("db.encryptKey")
		};

		setKeys( keys );

		return this;

	}
	
	public Any function get( required String path="" ){

		if ( Len( arguments.path ) ) {

			var keys = getkeys();

			return StructGet( "keys.#arguments.path#" );

		} 

		return getKeys();

	}

}
