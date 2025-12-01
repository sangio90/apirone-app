component extends="com.apirone.core.root.Application" {

    this.name = "apirone-app";
	this.nullSupported = true;
	this.pdf.fontDirectory = "/assets/main/fonts";
	this.customtagPaths = [ "/apps/utils/ctags/" ];

	this.bufferOutput = false;
	this.compression = true;

	this.charset.web      = "UTF-8";
	this.charset.resource = "UTF-8";

	public Boolean function onApplicationStart() {

		super.onApplicationStart();

		if ( !StructKeyExists( application, "cbBootstrap" ) ) {
			loadColdbox()
		}

		return true;

	}

	public Boolean function onSessionStart( string targetPage ) {

		startUser();

	}

	public Boolean function onRequestStart( string targetPage ) {

		param request.loadFromVerticale = true;

		SetLocale( "italian (italy)" );

		request.isDev = super.isDev;

		if( !application.keyExists( "counter" ) ) {
			application.counter = 100;
		}

        if ( !session.keyExists( "user" ) OR IsNull( session.user ) ) { //extra check
            startUser()
        }

		if ( super.isDev() OR url.keyExists("reinit") ) {

			//super.clearContainer();

			//onApplicationStart();
			application.counter++;
		}

		if ( url.keyExists("reset") ) {

			cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# reset all");

			url.fwreinit = 1;

			CacheRemoveAll();

			onApplicationStart();

			super.clearContainer();
			
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
		
		var COLDBOX_APP_ROOT_PATH = GetDirectoryFromPath( GetCurrentTemplatePath() );
		var COLDBOX_APP_MAPPING   = "";
		var COLDBOX_CONFIG_FILE   = "config.Coldbox";
		var COLDBOX_APP_KEY       = "";
		var COLDBOX_FAIL_FAST     = true;

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
