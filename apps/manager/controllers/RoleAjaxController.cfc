component extends="com.apirone.core.controller.AbsController" {

	function get( event, rc, prc ){
		var data = [];

		var result = super.getResult();

		var role = super.fire( "role.get", [ rc.roleId ] );

		result.setTotal( data.len() );
		result.setCount( data.len() );
		result.setData( role );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var messageId = "role.saved";

		var result = super.getResult();
		
		var bean = super.bean( "Role" );

		bean.setId( json.id );//
		bean.setName( json.name );
		bean.setQuotationMaxAmount( json.quotationMaxAmount );
		bean.setQuotationMaxDiscount( json.quotationMaxDiscount );

		var thisId = super.fire( "role.update", [ bean ] )	
			
		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}
}
