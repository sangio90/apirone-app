component extends="com.apirone.core.controller.AbsController" {
	
	function reassign( event, rc, prc ){
		var result = super.getResult();
		var args = {};

		var messageId = "price.reassigned";

		var result = super.fire( "price.massiveReassign", argumentCollection = rc );

		dump( result );

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = result } );

		event.setValue( "result", result );
	
	}
	
}
