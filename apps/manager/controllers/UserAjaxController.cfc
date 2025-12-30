component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var result = super.getResult();
        var memy = super.getMementify()

        var args = super.paramsFromUrl()
        
        var rows = super.fire("user.search", args)

        var data = memy.convertList( rows.getData(), "list" );

        result.setTotal( rows.getTotal() );
        result.setCount( rows.getCount() );
        result.setData( data );

		event.setValue( "result", result );
        
    }

	function save( event, rc, prc ){
		var result  = super.getResult();

		var user    = super.bean( "User" );
		var account = super.bean( "Account" );
		var role    = super.bean( "Role" );
		var status  = super.bean( "Status" );
		var lang    = super.bean( "Lang" );

		var thisId    = "";
		var messageId = "";

		var json = DeserializeJSON( getHTTPRequestData().content );

		user.setId( json.id );
		//user.setEmail( json.email );
		user.setName( json?.name );
		//user.setPwd( json?.pwd );
		user.setPhone( json?.phone );
		user.setStatus( status.setId( json.status.id ) );
		user.setAccount( account.setId( json.account.id ) );
		user.setLang( lang.setId( json.lang.id ) );
		user.setRole( role.setId( json.role.id ) );

		if ( !len( json.id ) ) {
			messageId = "user.created";
			thisId    = super.fire( "user.create", [ user ] );
		} else {
			messageId = "user.updated";
			thisId    = super.fire( "user.update", [ user ] );
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}


	function delete( event, rc, prc ){
        
        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "user.deletedAllRecords";

        var errors = [];
        var payload = "";

        var ids = ListToArray( list );

        for( var id in ids ) {
            var outcome = super.fire( "user.delete", [ id ] );

            if( outcome.getStatus() == "ERROR"  ) {
                errors.add( { "message" = "Non sono riuscito a cancellare l'id #id#" } )
            }

        }

        if( errors.len() ) {
            messageId = "user.deletedNotAllRecords"
            payload = { "errors": errors } ;
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}    

}
