component accessors="true"{

	public function init( required String filePath ){
		variables.filePath = arguments.filePath;
		return this
	}

	public function debug( required message, category="NONE", extraInfo="" ){
		arguments.severity = "DEBUG";
		return logMessage( argumentCollection=arguments );
	}

	public function info( required message, category="NONE", extraInfo="" ){
		arguments.severity = "INFO";
		return logMessage( argumentCollection=arguments );
	}

	public function warn( required message, category="NONE", extraInfo="" ){
		arguments.severity = "WARN";
		return logMessage( argumentCollection=arguments );
	}

	public function error( required message, category="NONE", extraInfo="" ){
		arguments.severity = "ERROR";
		return logMessage( argumentCollection=arguments );
	}

	public function fatal( required message, category="NONE", extraInfo="" ){
		arguments.severity = "FATAL";
		return logMessage( argumentCollection=arguments );
	}

	

    /*=========
        Private methods
    =========*/

	private Void function logMessage( required message, required severity, category="", extraInfo="" ){

		arguments.message = trim( arguments.message );

		var msg = replace( arguments.message, '"', '""', "all" );
		msg = replace( msg, "#chr(13)##chr(10)#", ' ', "all" );
		msg = replace( msg, chr(13), ' ', "all" );

		var extra = formatExtraInfo( arguments.extraInfo );

		var timestamp = now();

		var entry = '"#arguments.severity#", "#cgi.remote_addr#", "#DateTimeFormat( timestamp, "yyyy-mm-dd HH:nn:ss.ll" )#", "#arguments.category#", "#message#", #extra#';

		var path = GetDirectoryFrompath( variables.filePath );
		
		if( !DirectoryExists( path ) ) {
			DirectoryCreate( path )
		}

		cffile( action="append" file="#variables.filePath#" output="#entry#" );

	}

	private String function formatExtraInfo( required Any data ){

		var ret = "";

		if ( isObject( arguments.data ) ) {
			ret = SerializeJSON( arguments.data );
		} else {
			ret = '"#arguments.data#"';
		}

		return ret;

	}

}