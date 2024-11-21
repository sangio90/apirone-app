component output="true" accessors="true" {
			
	property name="keys" type="Struct";

	public Configuration function init(){

		var settings = new config.Settings();
		
		var keys = {
			"appName"    = settings.get('app.name'),
			"appVersion" = settings.get('app.version'),
			"owner"      = {
				"name" = settings.get('owner.namename'),
				"vat" = settings.get('owner.namevat'),
				"email" = settings.get('owner.nameemail')
			},
			"filesHost": "#settings.get('files.host')#",
			"imageVersions" = {
				"sizes" = {
					"small" = 300,
					"medium" = 600,
				},
				"crops" = {
					"thumbnail" =  '50x50'
				}
			},
			"encryptKey": settings.get('db.encryptKey'),
			"variantTypeDefault": "c5eb08a5-48f3-4b4b-abf7-b9b01ed05ceb",
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
