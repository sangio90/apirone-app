component {

    pageEncoding "UTF-8";
    
    variables.settings = new config.Settings();
    
    this.name              = "zerobenefit-core";
    this.nullSupport       = true;
    this.sessionManagement = true;
    this.sessionTimeout    = CreateTimeSpan( 0, 1, 0, 0 );
    this.scriptProtect     = "url,cookie,cgi";

    this.charset.web      = "UTF-8";
    this.charset.resource = "UTF-8";

    this.mailservers =[ {
		host: variables.settings.get('mailserver.host'),
		port: variables.settings.get('mailserver.port'),
		username: variables.settings.get('mailserver.username'),
		password: variables.settings.get('mailserver.pwd'),
		ssl: false,
		tls: true,
		lifeTimespan: CreateTimeSpan( 0, 0, 1, 0 ),
		idleTimespan: CreateTimeSpan( 0, 0, 0, 10 )
    } ];

    this.datasources["zerobenefit"] = {
        type     = "postgresql", 
        host     = variables.settings.get('db.host'),
        database = variables.settings.get('db.name'),
        port     = variables.settings.get('db.port'),
        username = variables.settings.get('db.username'),
        password = variables.settings.get('db.pwd')
    };
   
    this.cache.connections["DefaultCache"] = {
        class         = "org.lucee.extension.cache.eh.EHCache",
        bundleName    = "ehcache.extension",
        bundleVersion = "2.10.0.31",
        storage       = false,
        default       = "object"
    };

    this.cache.object = "DefaultCache";

    this.mappings[ "/wirebox" ]    = ExpandPath( "/modules/wirebox/" );
    this.mappings[ "/coldbox" ]    = ExpandPath( "/modules/coldbox/" );
    this.mappings[ "/dataMapper" ] = ExpandPath( "/modules/external/dataMapper/" );

    public boolean function onRequestStart(){

        return true;

    }

    public Boolean function onSessionStart(){

        return true;
    }

    public Boolean function OnSessionEnd(){
        return true;
    }

    public Boolean function onApplicationStart(){

        variables.settings = new config.Settings();

        cffile( action="append" file="#ExpandPath('/application.log')#" output="#now()# - CORE:onApplicationStart" );

        startFramework();

        return true;
    }

    public Boolean function OnMissingTemplate(){

        cfheader( statusCode="404" statusText="Not found");
                
        echo("404. Not found");

        return true;
    }
    
    /*
        Private methods 
    */

    private function startFramework(){

        cffile( action="append" file="#ExpandPath('/application.log')#" output="#now()# - CORE:startFramework" );

        new com.apirone.core.loading.Bootstrapper();

    }

    private String function getVersion() {

        return this.version;
        
    }

    private String function isDev() {

        return ( 
            ( ListLast( cgi.SERVER_NAME, "." ) IS "local" )
            OR 
            ( cgi.SERVER_NAME CT "localhost" ) 
        );
        
    }

}
