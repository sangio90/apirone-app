component extends="com.apirone.core.controller.AbsController" {

	function run( event, rc, prc ){
		var result = super.getResult();

		var data = super.service( "VerticaleSync" ).run( session.user.getId() );

		result.setData( data );

		event.setValue( "result", result );
	}

	function status( event, rc, prc ){
		var result = super.getResult();

		var data = super.service( "VerticaleSync" ).getStatus();

		result.setData( data );

		event.setValue( "result", result );
	}

}
