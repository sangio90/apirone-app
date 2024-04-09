component extends="com.apirone.core.root.Application" {

  	this.name = "tests";
  	this.sessionmanagement = "true";
    this.nullSupport = "true";

    variables.settings = new config.Settings();

    this.cache.object = "DefaultCache";

  	this.mappings[ "/testbox" ] = ExpandPath( "/modules/testbox/" );

    this.customTagPaths = ["/external/ctags/MagickTag"];

  	public boolean function onRequestStart(){
     	return true;
  	}

}
