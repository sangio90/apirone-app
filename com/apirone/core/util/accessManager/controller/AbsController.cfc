component output="false" accessors="true" {

    public Any function fire( required String action, Any payload ){

        var service = ListFirst( arguments.action, "." );
        var method  = ListLast( arguments.action, "." );

        var instance = model().getInstance('#service#Service');
        
        return invoke( instance, method, arguments.payload );

    }

    public function setThrow(
        required String message,
        required String detail=""
    ){

        throw(
            type    = "AccessManager.errors.InvalidCall",
            message = arguments.message,
            detail  = arguments.detail
        );

    }

    public Any function model(){

        return server[ "wireBox-apirone" ];

    }    

}
