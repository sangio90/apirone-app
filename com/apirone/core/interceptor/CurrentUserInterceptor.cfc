component extends="coldbox.system.Interceptor" {

	function preProcess(
		event,
		data,
		buffer,
		rc,
		prc
	){

		if( session.user.isLogged() ){
		
			var module = prc.currentRoutedModule;
			var model  = getContainer();

			if ( module == "manager" ) {
				// add list variables for logged user
				prc.users  = model.getInstance( "UserService" ).list( accountId = prc.user.getAccount().getId(), statusId = "ACT" );
			}
		}

	}

	private Struct function getContainer(){
		return server[ "wireBox-apirone" ];
	}

}
