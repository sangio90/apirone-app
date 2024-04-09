component accessors="true"{

    property name="controllers" type="Struct";
    property name="controllerPath" type="String";

    public AccessManager function init( required String controllerPath ){

        var instance = new controller.DefaultController();
        var controllers = { 'DefaultController' = instance };
        
        setControllers( controllers );
        
        setControllerPath( Replace( arguments.controllerPath, "/", ".", "ALL" ) );

        return this;

    }

    public Any function exec( 
        required Any user, 
        required String action,
                 Any payload = nullValue()
    ){
        
        var ret = "";

        var method     = ListLast( arguments.action, '.' );
        var controller = ListFirst( arguments.action, '.' ) & "Controller";

        /*
            se è un valore piano, viene convertito in array
        */

        //arguments.payload = IsSimpleValue( arguments.payload ) ? [ arguments.payload ] : arguments.payload;
        //dump(arguments.payload);
        //abort;
        
        var dotPath = "#getControllerPath()#.#controller#";
        var filePath = "/" & Replace( dotPath, ".", "/", "ALL" ) & ".cfc";

        /*
            se il controller esiste
        */
        if ( FileExists( ExpandPath( filePath ) ) ) {

            addLog('Controller [ #filePath# ] exists');
            
            var instance = "";

            if( StructKeyExists( getControllers(), controller ) ) {

                addLog('#controller# exists in memory')

                instance = getControllers()[ controller ];

                //var path = ExpandPath('/../repository/private/log/');


            } else {

                addLog('#controller# created in memory')

                instance = CreateObject( "component", dotPath );
                
                addController( controller, instance );

            }

            var funcs = getMetaData( instance ).functions;

            /*
                [ROB] se il metodo nella classe esiste...
            */

            for ( var func in funcs ) {
                
                if ( func.name == method ) {

                    return invoke( instance, method, { argumentCollection = arguments } );

                }
            }

            addLog('Controller [ #filePath# ] exists but not method [ #method# ]. Load DefaultController');

            ret = getDafaultController().fire( arguments.user, arguments.action, arguments.payload );


        } else {

            addLog('Controller [ #filePath# ] not exists. Load DefaultController');

            ret = getDafaultController().fire( arguments.user, arguments.action, arguments.payload );
            
        }

        return ret;

    }


    /*
        private method
    */

    private Struct function getDafaultController() {

        return getControllers()[ 'DefaultController' ];

    }

    private Avoid function addController( required String key, required Struct instance ) {

        var controllers = getControllers();

        StructAppend( controllers, { '#arguments.key#' = arguments.instance } );

        setControllers( controllers );

    }

    private Avoid function addLog( required String message ) {

		var fileName = "access-manager.log";
		var path = ExpandPath('/../repository/private/logs/');

		if ( !DirectoryExists( path ) ) {
			DirectoryCreate( path )
		}

		cffile( 
			action="append" 
			file="#path#/#fileName#" 
			output="#now()#;#arguments.message#",
			nameconflict="overwrite"
		);

    }

}