component extends="com.apirone.core.root.Application" {

    this.name = "apirone-site";
	this.pdf.fontDirectory = "/assets/main/fonts";
	this.customtagPaths = [ "/apps/utils/ctags/" ];

	public Boolean function onApplicationStart() {

		//cffile( action="append" file="#ExpandPath('/debug.log')#" output="#now()# - Root:onApplicationStart" );

		super.onApplicationStart();
		//abort;

		if ( !StructKeyExists( application, "cbBootstrap" ) OR StructKeyExists( url, "reinit" )) {

			loadColdbox()

		}

		return true;

	}

	public Boolean function onSessionStart( string targetPage ) {

		startUser();

	}


	public Boolean function onRequestStart( string targetPage ) {

		SetLocale("italian (italy)");

		request.isDev = super.isDev;

		if( !application.keyExists( "counter" ) ) {
			application.counter = 100;
		}


        if ( !StructKeyExists( session, "user" ) ) {
            startUser()
        }

		if ( super.isDev() OR url.keyExists("reinit") ) {

			onApplicationStart();
			
			application.counter++;

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

	public Void function loadColdbox(){
		
		//cffile( action="append" file="#ExpandPath('/debug.log')#" output="#now()# - Root:loadColdbox" );

		var COLDBOX_APP_ROOT_PATH = GetDirectoryFromPath( GetCurrentTemplatePath() );
		var COLDBOX_APP_MAPPING   = "";
		var COLDBOX_CONFIG_FILE   = "config.Coldbox";
		var COLDBOX_APP_KEY       = "";
		var COLDBOX_FAIL_FAST     = false;

		application.cbBootstrap = new coldbox.system.Bootstrap(
			COLDBOX_CONFIG_FILE,
			COLDBOX_APP_ROOT_PATH,
			COLDBOX_APP_KEY,
			COLDBOX_APP_MAPPING,
			COLDBOX_FAIL_FAST
		);

		application.cbBootstrap.loadColdbox();
	
	}

}
