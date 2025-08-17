component extends=".Application" {

  	this.sessionmanagement = "true";
    this.nullSupport = "true";

    variables.settings = new config.Settings();

    this.cache.object = "DefaultCache";

  	this.mappings[ "/testbox" ] = ExpandPath( "/modules/testbox/" );
  	this.mappings[ "/mementifier" ] = ExpandPath( "/modules/mementifier/" );

  	public boolean function onRequestStart( targetPage ){

		if( !application.keyExists("cbBootstrap") OR url.keyExists("reinit")) {
			super.loadColdbox()
		}

		//super.onRequestStart( targetPage )

     	return true;
  	}

}


