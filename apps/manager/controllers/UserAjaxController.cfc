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

		var account = super.bean( "Account" );
		var status  = super.bean( "Status" );
		var lang    = super.bean( "Lang" );

		var thisId    = "";
		var messageId = "";
		var roles     = [];

		var json = DeserializeJSON( getHTTPRequestData().content );

		account.setId( json.id );
		account.setEmail( json.email );
		account.setName( json?.name );
		account.setPwd( json?.pwd );
		account.setStatus( status.setId( json.status.id ) );

		if ( !len( json.id ) ) {
			messageId = "user.created";
			thisId    = super.fire( "user.create", [ account ] );
		} else {
			messageId = "user.updated";
			thisId    = super.fire( "user.update", [ account ] );
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}


	function delete( event, rc, prc ){
        
        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "account.deletedAllRecords";

        var errors = [];
        var payload = "";

        var ids = ListToArray( list );

        for( var id in ids ) {
            var outcome = super.fire( "account.delete", [ id ] );

            if( outcome.getStatus() == "ERROR"  ) {
                errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
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

    function updatePwd( event, rc, prc ){

        var user = prc.user;
        var result = super.getResult();
		var messageId = "line.deletedNotAllRecords"

        var raw  = GetHTTPRequestData().content;
        var json = DESerializeJSON( raw );

        var id = super.fire( "account.setPassword", { newPwd: json.pwd , accountId: json.accountId } );

		var message = super.completeMessage( "account.passwordUpdated" );

        result.setData( { "message" = message } );

        event.setValue( "result", result );

    }    

}
