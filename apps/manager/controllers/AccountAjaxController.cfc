component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var memy = super.getMementify()

        var args = super.paramsFromUrl()

		args["orderBy"] = [ { field = "account.email", desc = "asc" } ]
        
        var rows = super.fire("account.list", args );

		var data = memy.convertList( rows, "list" );
        
        result.setTotal( data.len() );
        result.setData( data );

		event.setValue( "result", result );
        
    }

	function emailExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.email = "";

		var result = super.fire( "account.emailExists", { email = rc.email, excludedId = rc.id } );

		event.setValue( "result", result );
	}
   
	function save( event, rc, prc ){
		var result  = super.getResult();

		var account = super.bean( "Account" );
		var status  = super.bean( "Status" );

		var thisId    = "";
		var messageId = "";

		var json = DeserializeJSON( getHTTPRequestData().content );

		account.setId( json.id );
		account.setEmail( json.email );
		account.setName( json?.name );
		account.setPwd( json?.pwd );
		account.setStatus( status.setId( json.status.id ) );

		if ( !len( json.id ) ) {
			messageId = "account.created";
			thisId    = super.fire( "account.create", [ account ] );
		} else {
			messageId = "account.updated";
			thisId    = super.fire( "account.update", [ account ] );
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
            messageId = "line.deletedNotAllRecords"
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

        var id = super.fire( "account.updatePassword", { newPwd: json.pwd , accountId: json.accountId } );

		var message = super.completeMessage( "account.passwordUpdated" );

        result.setData( { "message" = message } );

        event.setValue( "result", result );

    }    

}
