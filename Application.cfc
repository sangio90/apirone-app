component extends="com.apirone.core.root.Application" {

    this.name = "apirone-site";
	this.pdf.fontDirectory = "/assets/main/fonts";
	
	COLDBOX_APP_ROOT_PATH = GetDirectoryFromPath( GetCurrentTemplatePath() );
	COLDBOX_APP_MAPPING   = "";
	COLDBOX_CONFIG_FILE   = "config.Coldbox";
	COLDBOX_APP_KEY       = "";
	COLDBOX_FAIL_FAST     = false;

    //this.mappings[ "/coldbox" ] = ExpandPath( "/modules/coldbox/" );

	public Boolean function onApplicationStart() {

		cffile( action="append" file="#ExpandPath('/application.log')#" output="#now()# - Root:onApplicationStart" );

		super.onApplicationStart();

		//if ( !StructKeyExists( application, "cbBootstrap" ) OR StructKeyExists( url, "reinit" )) {

			cffile( action="append" file="#ExpandPath('/application.log')#" output="#now()# - Root:loadColdbox" );

			application.cbBootstrap = new coldbox.system.Bootstrap(
				COLDBOX_CONFIG_FILE,
				COLDBOX_APP_ROOT_PATH,
				COLDBOX_APP_KEY,
				COLDBOX_APP_MAPPING,
				COLDBOX_FAIL_FAST
			);

			application.cbBootstrap.loadColdbox();

		//}

		return true;
	
	}

	public Boolean function onSessionStart( string targetPage ) {

		//startCart();

		startUser();

	}


	public Boolean function onRequestStart( string targetPage ) {

		SetLocale("italian (italy)")

		cffile( action="append" file="#ExpandPath('/application.log')#" output="#now()# - app:onRequestStart" );

        if ( !StructKeyExists( session, "user" ) ) {
            startUser()
        }

		if ( super.isDev() OR url.keyExists("reinit") ) {

			url.fwreinit = 1;
			
			onApplicationStart();

		}

		application.cbBootstrap.onRequestStart( arguments.targetPage );

		return true;
	}


	/*
		private
	*/
	private Void function startUser(){
		session.user = new com.apirone.core.model.bean.User();
	}

}
