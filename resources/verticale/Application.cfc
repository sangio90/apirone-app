component{

    pageEncoding "UTF-8";

    this.name = "verticale-apir-server";

    variables.settings = new config.Settings();

	this.datasources[ "verticale" ] = {
		class            = "com.microsoft.sqlserver.jdbc.SQLServerDriver",
		bundleName       = "org.lucee.mssql",
		bundleVersion    = "12.2.0.jre8",
		connectionString = "jdbc:sqlserver://#variables.settings.get( "verticaledb.host" )#:#variables.settings.get( "verticaledb.port" )#;DATABASENAME=#variables.settings.get( "verticaledb.name" )#;SelectMethod=direct",
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

    public boolean function onRequestStart(){

        return true

    }

}
