component output="false" accessors="true" {

	property name="configuration" type="com.apirone.core.model.bean.Configuration";

	public Any function init(){
		setConfiguration( getContainer().getInstance( "Configuration" ) );
	}

	/*
		to remove
	*/
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

	/*
		to remove
	*/
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

	/*
		shorthands validation result
	*/
	public Any function getValidationResult(){
		var validationResult = new cbvalidation.models.result.ValidationResult();

		// ROB: overwrite buildin function because it is bugged
		validationResult.hasErrors = function( bean ){
			return validationResult.getAllErrorsAsStruct().len() > 0;
		}

		return validationResult;
	}

	public Any function getValidationError(){
		/*
			fields available:

			req message        = "";
			req field          = "";
				rejectedValue  = "";
				validationType = "";
				validationData = "";
				errorMetadata  = {};
		*/

		if ( !StructKeyExists( arguments, "field" ) ) {
			arguments.field = "generic";
		}
		var error = new cbvalidation.models.result.ValidationError();
		error.configure( argumentCollection = arguments );

		return error;
	}
	/*
		// shorthands validation result
	*/


	public Any function changeRole( required String roleId ){
		var found = false;

		for ( var role in session.user.getAccount().getRoles() ) {
			if ( role.getId() == roleId ) {
				found = true;
				break;
			}
		}

		if ( found ) {
			var role = service( "Role" ).get( roleId );
			session.user.setRole( role );

			return true;
		}

		return false;
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

		// StructDelete( bean, "$wbMixer" );

		return bean;
	}

	function buildTextBean( required Struct item, required string kindId ){
		var text   = bean( "Text" );
		var lang   = bean( "Lang" ).setId( "IT" );
		var status = bean( "Status" ).setId( "TRA" );
		var kind   = bean( "TextKind" ).setId( kindId );

		text.setLang( lang );
		text.setStatus( status );
		text.setId( item.id );
		text.setName( item.name );
		text.setKind( kind );

		return text;
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
	public String function getMessage( required String id, required String langId = "it" ){
		// id is a dotted path

		var messages = DeserializeJSON(
			FileRead( ExpandPath( "/config/assets/messages-#LCase( arguments.langId )#.json.cfm" ) )
		);

		if ( !keyPathExists( messages, arguments.id ) ) {
			FileAppend(
				file = ExpandPath( "/message-not-found.log" ),
				data = "#Now()#;messageIdNotFound:#arguments.id#;langId:#arguments.langId# #Chr( 13 )##Chr( 10 )#"
			);
			return "Not found"
		}

		return StructGet( "messages.#arguments.id#" );
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

	public Struct function getMementify(){
		return getContainer().getInstance( "Mementify" );
	}

	private Struct function logEvent(){
		var helper = getContainer().getInstance( "AuditHelper" );
		helper.logEvent( argumentCollection = arguments );
	}

	public Any function service( required String service ){
		var bean = getContainer().getInstance( "#arguments.service#Service" );
		return bean;
	}

	public Any function bean( required String type, Struct values = {} ){
		var bean = CreateObject( "com.apirone.core.model.bean.#arguments.type#" ).init();
		return bean;
	}

	public Array function eachParallelAndReorder( 		
			required array sourceArray,
			required function callbackFunction 
		){
			
		var udf = new com.apirone.core.util.Udf();

		var result = udf.eachParallelAndReorder( 
			argumentCollection = arguments 
		);
	
		return result;
	}


	/*
        private methods
    */

	public Struct function getContainer(){
		// TODO: use GetSystemPropOrEnvVar from Lucee 6.2.1
		return server[ "wireBox-apirone" ];
	}

	private Boolean function keyPathExists( structure, path ){
		var keys    = ListToArray( path, "." );
		var current = structure;

		for ( var key in keys ) {
			if ( !IsStruct( current ) || !StructKeyExists( current, key ) ) {
				return false;
			}
			current = current[ key ];
		}

		return true;
	}

}
