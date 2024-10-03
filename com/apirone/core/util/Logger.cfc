component accessors="true"{

	public function init( required String folder ){
		
		variables.folder = arguments.folder;
		
		return this
	}

	public function debug( required message="", required type="NONE", extraInfo="", file="" ){
		arguments.severity = "DEBUG";
		return logMessage( argumentCollection=arguments );
	}

	public function info( required message="", required type="NONE", extraInfo="", file="" ){
		arguments.severity = "INFO";
		return logMessage( argumentCollection=arguments );
	}

	public function warn( required message="", required type="NONE", extraInfo="", file="" ){
		arguments.severity = "WARN";
		return logMessage( argumentCollection=arguments );
	}

	public function error( required message="", required type="NONE", extraInfo="", file="" ){
		arguments.severity = "ERROR";
		return logMessage( argumentCollection=arguments );
	}

	public function fatal( required message="", required type="NONE", extraInfo="", file="" ){
		arguments.severity = "FATAL";
		return logMessage( argumentCollection=arguments );
	}


    /*=========
        Private methods
    =========*/

	private Void function logMessage( required message, required severity, type="", extraInfo="", file="" ){

		arguments.message = trim( arguments.message );

		var msg = Replace( arguments.message, '"', "'", "all" );
		msg = Replace( msg, "#chr(13)##chr(10)#", ' ', "all" );
		msg = Replace( msg, chr(13), ' ', "all" );

		var extra = formatExtraInfo( arguments.extraInfo );

		var timestamp = now();

		var fileName = "#LCase(arguments.severity)#.log";

		if ( len( arguments.file ) ) {
			fileName = "custom-#arguments.file#.log";
		}

		var entry = '"#arguments.severity#", "#cgi.remote_addr#", "#DateTimeFormat( timestamp, "yyyy-mm-dd HH:nn:ss.ll" )#", "#arguments.type#", "#msg#", #extra#';

		if( !DirectoryExists( variables.folder ) ) {
			DirectoryCreate( variables.folder )
		}

		cffile( action="append" file="#variables.folder#/#fileName#" output="#entry#" );

	}

	private String function formatExtraInfo( required Any data ){

		var ret = "";

		if ( IsObject( arguments.data ) ) {
			ret = SerializeJSON( arguments.data );
		} else {
			ret = '"#arguments.data#"';
		}

		return ret;

	}

}