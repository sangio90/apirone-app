component extends="com.apirone.core.root.Application" {

    this.name = "apirone-site";
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

		SetLocale( "italian (italy)" );

		request.isDev = super.isDev;

		if( !application.keyExists( "counter" ) ) {
			application.counter = 100;
		}

        if ( !session.keyExists( "user" ) ) {
            startUser()
        }

		if ( super.isDev() OR url.keyExists("reinit") ) {

			//super.clearContainer()

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
