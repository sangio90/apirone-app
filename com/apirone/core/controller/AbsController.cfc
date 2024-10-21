component output="false" accessors="true" {

	property name="dataMapper" type="dataMapper.DataMapper";
	property name="configuration" type="com.apirone.core.model.bean.Configuration";
	property name="accessManager" type="com.apirone.core.util.accessManager.AccessManager";

    public Any function init(){

        setDataMapper( model().getInstance("DataMapper") );
        setAccessManager( model().getInstance("AccessManager") );
        setConfiguration( model().getInstance("Configuration") );

    }

    public Array function convertCbErrors( required Array errors ) {
        return errors
                .map( (error ) => {
                    return {
                        "field": error.getField(),
                        "type": error.getValidationType(),
                        "expected": error.getValidationData(),
                        "found": error.getRejectedValue(),
                        "message": error.getMessage(),
                        "details": error.getValidationData()
                    }
                })
    }

    public Void function setErrorResult( required Any event,  required Array errors = [] ) {

        var result = getResult();

        result.setData(convertCbErrors(errors));

        result.setStatus( 'ERROR' );
        event
            .getResponse()
                .setStatus( 400 )
                .setError( true )
                .setData( result );
    }


    public Struct function getConstraints( 
		required String entity,
		String profile = 'default'
	) {
		
		var constraints = deserializeJSON( fileRead(expandPath('/apps/api/constraints/#arguments.entity#.json') ) );
		
		return constraints[profile]

	}

    public Any function setAuthUser( required com.apirone.core.model.bean.Account account ){

        var user = bean("User");

        user.setAccount( arguments.account );
        
        user.setId( arguments.account.getId() );
        user.setName( arguments.account.getLogin() );

        session.user = user;

        return true;

    }

    public Any function logout(){

        var user = bean("User");

        session.user = user;

        return true;

    }      

    public Any function getResult(){

        var bean = bean("AjaxResult");
        
        bean.setUuid( LCase( CreateUUID() ) );
        bean.setStatus( "SUCCESS" );

        return bean;

    }      

    public Any function service( required String service ){

        var bean = model().getInstance("#service#Service");

        return bean;

    }      

    public Any function getCart(){

        return session.cart;

    }      

    public Any function setMessage( message="", type="success", title="" ){

        var title = "";

        switch( arguments.type ) {
            case "success":
                title = Len(arguments.title) ? arguments.title : 'Ok';
                break;
            case "error":
                title = Len(arguments.title) ? arguments.title : 'Errore';
                break;
            case "info":
                title = Len(arguments.title) ? arguments.title : 'Info';
                break;
            case "warning":
                title = Len(arguments.title) ? arguments.title : 'Attenzione';
                break;
        }

        flash.put( "message", { "type" = arguments.type, "message" = arguments.message, "title" = title } );

    }


    public Any function fire( action, payload=NullValue() ){

        var user = var event = application.cbController.getRequestService().getContext().getPrivateValue("user");

        var result = getAccessManager().exec( action=arguments.action, user=user, payload=arguments.payload );

        return result;

    }      
    
    public Any function getDataMapper(){

        return model().getInstance("DataMapper");

    }      
    
    public Any function model(){

        return server[ "wireBox-apirone" ];

    }    

    public Any function toStruct( required obj ){

        return DESerializeJSON( SerializeJSON( arguments.obj ) );

    }    

    public Any function bean( required String type ){

        return CreateObject( "com.apirone.core.model.bean.#arguments.type#" ).init();

    }

    // only message
    public String function message( required String id, required String lang=it ){ //id is a dotted path

		var messages = DeserializeJSON( FileRead(expandPath("/config/assets/messages/#LCase(arguments.lang)#.json.cfm") ) );

        return StructGet( "messages.#id#" );

    }

    // message and id
    public Struct function completeMessage( required String id, required String lang=it ){ //id is a dotted path

		var messages = DeserializeJSON( FileRead(expandPath("/config/assets/messages/#LCase(arguments.lang)#.json.cfm") ) );

        return { id : path, message = StructGet("message.#path#") };

    }

}
