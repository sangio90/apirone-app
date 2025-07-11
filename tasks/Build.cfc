component accessors="true" {

	property name="code" type="String" default="";
	property name="excludedDirectories" type="Array";

	function init() {

		var config = DESerializeJSON( FileRead( getCWD() & "/tasks/config.json.cfm" ) );

		var code = DateTimeFormat( now(), "yyyymmdd-HHnnss-lll" );

		setCode( code );
		setExcludedDirectories( config.excludedDirectories );

		addLog( "========================= START: #code#" );

	}

	function setup( required String env ) {

		print.greenLine( "Ssetup for [ #arguments.env# ] starting..." );

		print.greenLine( 'Stop server...' );
		command("server stop").run();

		createEnv( env=arguments.env );

		command("setup").run();
	
		print.greenLine( 'Start server...' );
		command("server start").run();

		addLog( "========================= END: #getCode()#" );

	}

	private function upload( zip ) {

		print.greenLine( "Start upload..." );

		var token = createToken();

        cfhttp( method="POST", url=variables.deployServer.url, result="result" ){
			cfhttpparam( type="header" name="X-Nimesia-DeployServer-Auth", value="Bearer #variables.deployServer.login#:#token#");
            cfhttpparam( type="File" name="zip" file=zip );
        }

		var cwd = getCwd();
		
		// cffile( output=result, file=cwd & '/http-error.html', action="WRITE" )

		var json = DESerializeJSON(result.fileContent);	

		if ( json.message == 'OK' ) {
			
			print.greenLine( "...done." );
		
		} else {

			print.redLine( "...done with error: [ #json.message#, #result.statusCode# ]" );

		}

	}	

	public function createZip() {

		var current = getCwd();

		var zipsDir = "#current#/../zips/";

		var currVersion = trim( command('package show version').run( returnOutput=true ) );
		var version = Val( currVersion )+1;
		trim( command('package set version=#version#').run( returnOutput=true ) );

		var slug = trim( command('package show slug').run( returnOutput=true ) );

		var dirName = "#slug#_#DateTimeFormat( now(), "yyyymmdd" )#_#version#";
		
		var containerDir = "#current#/../zips/#dirName#";
		var sourceDir = "#containerDir#/code";

		//print.greenLine( '#sourceDir#/#slug#.txt' );

		print.greenLine( "Create zip from: #current#" );

		var excludes = getExcludPattern();

		var files = globber( current & "**" )
						.setExcludePattern( excludes )
						.matches();

		if ( !DirectoryExists( sourceDir ) )  {
			DirectoryCreate( sourceDir );
		}

		FileWrite( file="#sourceDir#/#slug#.txt", data="Build on #DateTimeFormat(now(), 'dd/mm/yyyy HH:nn:ss')#; version #version#" );

		print.greenLine( "Total files: #files.len()#" );

		for ( var item in files ) {
			if( FileExists( item )) {

				var myFile = Replace( item, current, '', 'ALL' );

				var currDir = GetDirectoryFromPath( myFile );

				if ( !DirectoryExists( sourceDir & "/" & currDir ) ) {
					DirectoryCreate( sourceDir & "/" & currDir );
				}

				FileCopy(item, sourceDir & "/" & myFile );

			}
			
		}

		cfzip( action="zip", source=containerDir, file=zipsDir & "/" & dirName & ".zip", recurse=true );

		print.greenLine( '... zip created in [ #dirName#.zip ]!' );

		return;

	}		


	/*
		private methods
	*/

	private function clearEnv( required String env ) {

		print.greenLine( 'Clear env [ #arguments.env# ]...' );

		var dir = getCwd();
		var files;

		cfdirectory( directory="#dir#", action="list", filter=".server*env", name="files" );

		for ( var file in files ) {
			cffile( file="#dir#/#file.name#", action="delete" );
		}

		print.greenLine( '... done.' );

	}

	private function createEnv( required String env ) {

		print.greenLine( 'Create env [ #arguments.env# ]...' );

		var dir = getCwd();
		var envItems = [:];
		var localItems = [:];
		var mainItems = [:];

		var timeStamp = getCode();

		var envFile = ".env" ;

		clearEnv( arguments.env );

		var mainConfig  = "#dir#/tasks/main.properties";
		var envConfig   = "#dir#/tasks/envs/#arguments.env#.properties"; // develop / prod
		var localConfig = "#dir#/tasks/local.properties";

		if ( !FileExists( envConfig ) ) {

			print.whiteOnRedLine( "Env file [ #envConfig# ] not exists. Exit." );
			setExitCode( 601 );

		} else {

			var envItems = getStructFromPropFile( envConfig );

		}

		if ( FileExists( mainConfig ) ) {

			var mainItems = getStructFromPropFile( mainConfig );

		}

		if ( FileExists( localConfig ) ) {

			var localItems = getStructFromPropFile( localConfig );

		}

		// merge envs file. local commands!
		StructAppend( mainItems, envItems, true );
		StructAppend( mainItems, localItems, true );

		mainItems.put( "app.version", trim( command('package show version').run( returnOutput=true ) ) );

		var serverItems = orderStruct( mainItems );

		if ( FileExists( "#dir#/#envFile#" ) ) {
			FileDelete( "#dir#/#envFile#" );
		}

		for ( var item in serverItems ) {
			cffile( file="#dir#/#envFile#", action="append", output="#TRim( item )#=#TRim( serverItems[item] )#" );
		}

		print.greenLine( '... done.' );

		return mainItems;

	}

	private function getStructFromPropFile( required String file ) {

		var data = {};

		cfloop( file=arguments.file, item="line" ) {

			var pos = find( "=", line );

			// line should have at least  a "=" and not start with "#"
			if ( ( pos > 0 ) AND ( Left( line, 1 ) NEQ "##" ) ) {

				var key = Mid( line, 1, pos-1 );
				var value = Mid( line, pos+1, Len(line) );
	
				data[ key ] = value;

			}

		}

		return data;

	}

	private function addLog( required Any message, required String type="DEBUG" ) {

		var dir = getCwd();
		var msg = arguments.message;

		if ( !IsSimpleValue( arguments.message ) ) {
			msg = SerializeJSON( arguments.message );
		}

		FileAppend( 
			file=dir & "/setup.log", data="#now()#;#type#;#msg##chr(9)##chr(13)#" 
		);

	}	

	private Struct function orderStruct( required Struct data ) {

		var newStruct = [:];
		var structKeys = StructKeyArray( arguments.data );
		
		ArraySort( structKeys, "text", "asc" );

		for (var key in structKeys) {
			newStruct[ key ] = arguments.data[ key ];
		}

		return newStruct;
		
	}

	private Array function getExcludPattern() {

		var result = [];
		var current = getCWD();

		for( var item in getExcludedDirectories() ) {
			result.add( current & item )
		}

		return result;
		
	}	

	private String function createToken(){

		var stringToHash = Hash( Reverse( variables.deployServer.login ) ) & variables.deployServer.key;

		var ret = LCase( Left( Hash( stringToHash ), 20 ) );

		return ret;
	
	}

}
