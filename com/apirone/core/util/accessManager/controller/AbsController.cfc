component output="false" accessors="true" {

	public Any function fire( required String action, Any payload ){
		var service = ListFirst( arguments.action, "." );
		var method  = ListLast( arguments.action, "." );

		var instance = getModel().getInstance( "#service#Service" );

		return Invoke( instance, method, arguments.payload );
	}

	public function setThrow( required String message, required String detail = "" ){
		Throw(
			type    = "AccessManager.errors.InvalidCall",
			message = arguments.message,
			detail  = arguments.detail
		);
	}

	public Any function getModel(){
		return server[ "wireBox-apirone" ];
	}

}
