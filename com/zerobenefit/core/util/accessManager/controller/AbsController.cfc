component output="false" accessors="true" {

    /*
        [ROB] invoca direttamente il servizio
    */
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

    /*
        [ROB] facciamo "model" invece di "getModel" altrimenti si sovrascrive con le possibili proprietà dell'oggetto
    */
    public Any function model(){

        /*
            [ROB] questo andrebbe caricato al boot. ci pensiamo un attimo
        */
        return server[ "wireBox-zerobenefit" ];

    }    

}
