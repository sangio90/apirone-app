component extends="com.apirone.core.controller.AbsController" {

	function run( event, rc, prc ){
		var result = super.getResult();

		var data = super.service( "CrmSync" ).run( session.user.getId() );

		result.setData( data );

		event.setValue( "result", result );
	}

	function status( event, rc, prc ){
		var result = super.getResult();

		var data = super.service( "CrmSync" ).getStatus();

		result.setData( data );

		event.setValue( "result", result );
	}

}
