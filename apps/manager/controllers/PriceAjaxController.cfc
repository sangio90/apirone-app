component extends="com.apirone.core.controller.AbsController" {
	
	function reassign( event, rc, prc ){
		var result = super.getResult();
		var args = {};

		var messageId = "price.reassigned";

		for( var key in rc ){
			if ( Len( rc[ key ] ) ) { // only non empty
				args[ key ] = rc[ key ];
			}
		}

		var outout = super.fire( "price.massiveReassign", { argumentCollection = args } );

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = outout } );

		event.setValue( "result", result );
	
	}
	
}
