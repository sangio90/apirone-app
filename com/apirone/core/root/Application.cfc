component {

	pageEncoding = "UTF-8";

	variables.settings = new config.Settings();

	this.name                = "apirone-core";
	this.nullSupport         = true;
	this.sessionManagement   = true;
	this.sessionTimeout      = CreateTimespan( 0, 1, 0, 0 );
	this.scriptProtect       = "url,cookie,cgi";
	this.searchResults       = false;
	this.suppressWhiteSpaces = true;

	this.charset.web      = "UTF-8";
	this.charset.resource = "UTF-8";

	this.mailservers = [
		{
			host         = variables.settings.get( "mailserver.host" ),
			port         = variables.settings.get( "mailserver.port" ),
			username     = variables.settings.get( "mailserver.username" ),
			password     = variables.settings.get( "mailserver.pwd" ),
			ssl          = false,
			tls          = true,
			lifeTimespan = CreateTimespan( 0, 0, 1, 0 ),
			idleTimespan = CreateTimespan( 0, 0, 0, 10 )
		}
	];

	this.datasources[ "apirone" ] = {
		type     = "postgresql",
		host     = variables.settings.get( "db.host" ),
		database = variables.settings.get( "db.name" ),
		port     = variables.settings.get( "db.port" ),
		username = variables.settings.get( "db.username" ),
		password = variables.settings.get( "db.pwd" )
	};

	this.datasources[ "verticale" ] = {
		class            = "com.microsoft.sqlserver.jdbc.SQLServerDriver",
		bundleName       = "org.lucee.mssql",
		bundleVersion    = "12.2.0.jre8",
		connectionString = "jdbc:sqlserver://#variables.settings.get( "verticaledb.host" )#:#variables.settings.get( "verticaledb.port" )#;DATABASENAME=#variables.settings.get( "verticaledb.name" )#;SelectMethod=direct",
		//connectionString = "jdbc:sqlserver://192.168.0.201:#variables.settings.get( "verticaledb.port" )#;DATABASENAME=#variables.settings.get( "verticaledb.name" )#;SelectMethod=direct",
		username         = variables.settings.get( "verticaledb.username" ),
		password         = variables.settings.get( "verticaledb.pwd" ),
		// optional settings
		connectionLimit  = -1, // default:-1
		liveTimeout      = 15, // default: -1; unit: minutes
		validate         = false // default: false
	};

	this.datasources[ "verticaleExport" ] = {
		class            = "com.microsoft.sqlserver.jdbc.SQLServerDriver",
		bundleName       = "org.lucee.mssql",
		bundleVersion    = "12.2.0.jre8",
		connectionString = "jdbc:sqlserver://#variables.settings.get( "verticaledb.host" )#:#variables.settings.get( "verticaledb.port" )#;DATABASENAME=VERTICALE_WEB_DATA;SelectMethod=direct",
		username         = variables.settings.get( "verticaledb.username" ),
		password         = variables.settings.get( "verticaledb.pwd" ),
		connectionLimit  = -1, // default:-1
		liveTimeout      = 15, // default: -1; unit: minutes
		validate         = false // default: false
	};

	this.cache.connections[ "DefaultCache" ] = {
		class         = "org.lucee.extension.cache.eh.EHCache",
		bundleName    = "ehcache.extension",
		bundleVersion = "2.10.0.31",
		storage       = false,
		default       = "object",
		custom        = { maxElementsInMemory: 10000 }
	};

	this.cache.object = "DefaultCache";

	this.mappings[ "/coldbox" ]     = ExpandPath( "/modules/coldbox/" );
	this.mappings[ "/dataMapper" ]  = ExpandPath( "/modules/external/dataMapper/" );
	this.mappings[ "/auditLogger" ] = ExpandPath( "/com/apirone/core/util/auditLogger/" );

	public Boolean function onApplicationStart(){
		return true;
	}

	public Void function clearContainer(){
		if ( server.keyExists( "wireBox-apirone" ) ) {
			server[ "wireBox-apirone" ].clearSingletons();
			FileAppend( ExpandPath( "/debug.log" ), "#Now()# - clearContainer" );
		}
	}

	public Boolean function OnMissingTemplate(){
		cfheader( statusCode = "404", statusText = "Not found" );

		Echo( "404. Not found" );

		return true;
	}

	/*
        Private methods
    */

	private String function getVersion(){
		return this.version;
	}

	private String function isDev(){
		return (
			( Right( cgi.SERVER_NAME, 5 ) IS "local" )
			OR
			( cgi.SERVER_NAME CONTAINS "localhost" )
		);
	}

}
