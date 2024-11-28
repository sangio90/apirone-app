component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = super.getDataMapper()

        var args = super.paramsFromUrl()
        
        var rows = super.fire("account.search", args).getData();
        
        for ( var row in rows ) {

            var obj = dm.convert( row, "Account", true );
            data.add( obj );

        }

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
		var lang    = super.bean( "Lang" );

		var thisId    = "";
		var messageId = "";
		var roles     = [];

		var json = DeserializeJSON( getHTTPRequestData().content );

		account.setId( json.id );
		account.setEmail( json.email );
		account.setName( json.name );
		account.setPwd( json.pwd );
		account.setPhone( json.phone );
		account.setLang( lang.setId( json.lang.id ) );
		account.setStatus( status.setId( json.status.id ) );

		for ( var thisRole in json.selectedRoles ) {

			var role   = super.bean( "Role" );

			role.setId( thisRole.id );
			roles.add( role );
		}

		account.setRoles( roles );

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


}
