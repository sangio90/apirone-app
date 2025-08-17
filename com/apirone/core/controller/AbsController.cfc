component output="false" accessors="true" {

	property name="configuration" type="com.apirone.core.model.bean.Configuration";

	public Any function init(){
		setConfiguration( getContainer().getInstance( "Configuration" ) );
	}

	public Array function convertCbErrors( required Array errors ){
		return errors.map( ( error ) => {
			return {
				"field"    = error.getField(),
				"type"     = error.getValidationType(),
				"expected" = error.getValidationData(),
				"found"    = error.getRejectedValue(),
				"message"  = error.getMessage(),
				"details"  = error.getValidationData()
			}
		} )
	}

	public Void function setErrorResult( required Any event, required Array errors = [] ){
		var result = getResult();

		result.setData( convertCbErrors( errors ) );

		result.setStatus( "ERROR" );
		event
			.getResponse()
			.setStatus( 400 )
			.setError( true )
			.setData( result );
	}


	public Struct function getConstraints( required String entity, String profile = "default" ){
		var constraints = DeserializeJSON(
			FileRead( ExpandPath( "/apps/api/constraints/#arguments.entity#.json" ) )
		);

		return constraints[ profile ]
	}

	public Any function setAuthUser( required com.apirone.core.model.bean.Account account ){
		var user = bean( "User" );

		user.setAccount( arguments.account );

		user.setId( arguments.account.getId() );
		user.setName( arguments.account.getEmail() );
		user.setRole( arguments.account.getRoles()[ 1 ] );

		session.user = user;

		return true;
	}

	public Any function logout(){
		var user = bean( "User" );

		session.user = user;

		return true;
	}

	public Any function getResult(){
		var bean = bean( "AjaxResult" );

		bean.setUuid( LCase( CreateUUID() ) );
		bean.setStatus( "SUCCESS" );

		return bean;
	}

	public Any function setMessage(
		message = "",
		type    = "success",
		title   = ""
	){
		var title = "";

		switch ( arguments.type ) {
			case "success":
				title = Len( arguments.title ) ? arguments.title : "Ok";
				break;
			case "error":
				title = Len( arguments.title ) ? arguments.title : "Errore";
				break;
			case "info":
				title = Len( arguments.title ) ? arguments.title : "Info";
				break;
			case "warning":
				title = Len( arguments.title ) ? arguments.title : "Attenzione";
				break;
		}

		flash.put(
			"message",
			{
				"type"    = arguments.type,
				"message" = arguments.message,
				"title"   = title
			}
		);
	}


	public Any function fire( required String action, payload = NullValue() ){
		if ( ListLen( action, "." ) != 2 ) {
			Throw(
				type    = "apirone.AbsController.ActionNotHasTwoPart",
				message = "Action [#arguments.action#] must have two part: controller.method."
			);
		};

		var user = application.cbController
			.getRequestService()
			.getContext()
			.getPrivateValue( "user" );

		var result = getAccessManager().exec(
			action  = arguments.action,
			user    = user,
			payload = arguments.payload
		);
		getContainer().getInstance( "CacheManager" );

		return result;
	}

	public Any function toStruct( required obj ){
		return DeserializeJSON( SerializeJSON( arguments.obj ) );
	}


	public Boolean function isUuid( required String uuid ){
		if ( ReFind( "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", arguments.uuid ) == 0 ) {
			return false;
		}

		return true;
	}

	public String function getTempDir(){
		var tempDir = ExpandPath( "/../repository/private/_tmp" );

		DirectoryCreate( tempDir, true, true );

		return tempDir;
	}

	public Struct function paramsFromUrl(){
		param url.page  = 1;
		param url.count = 15;

		var params = {}

		for ( var thisParam in url ) {
			var value = url[ thisParam ];

			if ( thisParam != "orderBy" ) {
				if ( Len( value ) ) {
					params[ thisParam ] = url[ thisParam ];
				}
			} else {
				/*
                    "orderBy" field
                */

				var dir   = "asc";
				var count = ListLen( value, "-" );
				var field = ListFirst( value, "-" );

				/* prefix from UI
                if( Len( arguments.prefix ) ) {
                    field = arguments.prefix & "." & listFirst( value, "-" );
                }
                */

				if ( count > 1 ) {
					dir = ListLast( value, "-" );
				}

				params[ "orderBy" ] = [ { field = field, dir = dir } ];
			}
		}

		/*
            paging
        */

		if ( url.keyExists( "count" ) ) {
			params[ "limit" ] = url.count;

			if ( url.keyExists( "page" ) ) {
				params[ "offset" ] = ( url.page - 1 ) * url.count;
			}
		}

		return params;
	}

	public Any function getCategoriesAsJSON(){
		var data = [];

		var categories = this.service( "ProductCategory" ).list();

		for ( var thisCategory in categories ) {
			var category = getDataMapper().convert( thisCategory, "ProductCategory", true );

			data.add( category );
		}

		return data;
	}

	// only message
	public String function message( required String id, required String lang = "it" ){
		// id is a dotted path

		var messages = DeserializeJSON(
			FileRead( ExpandPath( "/config/assets/messages-#LCase( arguments.lang )#.json.cfm" ) )
		);

		return StructGet( "messages.#id#" );
	}

	// message and id
	public Struct function completeMessage( required String id, required String langId = "it" ){
		// id is a dotted path

		var messages = DeserializeJSON(
			FileRead( ExpandPath( "/config/assets/messages-#LCase( arguments.langId )#.json.cfm" ) )
		);

		var text = StructGet( "messages.#arguments.id#" );

		if ( !IsSimpleValue( text ) ) {
			FileAppend(
				file = ExpandPath( "/message-not-found.log" ),
				data = "#Now()#;messageIdNotFound:#arguments.id#;langId:#arguments.langId# #Chr( 13 )##Chr( 10 )#"
			);
		}

		return {
			"id"   = arguments.id,
			"text" = IsSimpleValue( text ) ? text : "String not found"
		};
	}


	/*
        some shorthads
    */

	public Struct function getDataMapper(){
		return getContainer().getInstance( "DataMapper" );
	}

	public Struct function getLogger(){
		return getContainer().getInstance( "Logger" );
	}

	public Struct function getAuditLogger(){
		return getContainer().getInstance( "AuditLogger" );
	}

	public Struct function getAccessManager(){
		return getContainer().getInstance( "AccessManager" );
	}

	public Struct function getCacheManager(){
		return getContainer().getInstance( "CacheManager" );
	}	

	public Any function service( required String service ){
		var bean = getContainer().getInstance( "#arguments.service#Service" );
		return bean;
	}	

	/*
	public Any function bean( required String type ){
		//return CreateObject( "com.apirone.core.model.bean.#arguments.type#" ).init();
	}
	*/

	public Any function bean( required String type, Struct values = {} ){
		var bean = getContainer().getInstance("com.apirone.core.model.bean.#type#");
		return bean;
	}




	/*
        private methods
    */

	public Struct function getContainer(){
		// TODO: use GetSystemPropOrEnvVar from Lucee 6.2.1

		return server[ "wireBox-apirone" ];
	}

}
