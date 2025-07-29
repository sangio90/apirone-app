component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();

		var params = super.paramsFromUrl();

        var rows = super.fire( "profile.search", params );

        for ( var row in rows.getData() ) {
            var obj = dm.convert( row, "Profile", true );
            data.add( obj );
        }

        result.setTotal( rows.getTotal() );
        result.setCount( rows.getCount() );
        result.setData( data );

        event.setValue( "result", result );
        
    }

	function save( event, rc, prc ){

		var json = deserializeJSON( getHTTPRequestData().content );

        var categories = [];

		var thisId    = "";
		var messageId = "";
		var texts     = [];
		
		var result = super.getResult();

		var profile   = super.bean( "Profile" );

		profile.setId( json.id );
		profile.setFirstName( json.first_name );
		profile.setLastName( json.last_name );
		profile.setCompany( json.company );
		profile.setVatNumber( json.vat_number );
		profile.setEmail( json.email );
		profile.setPhone( json.phone );
		profile.setState( json.state );
		profile.setCity( json.city );
		profile.setPostalCode( json.postal_code );
		profile.setStreet( json.street );
		profile.setCode( json.code );
        profile.setCountry( type.setId( json.country.id ) );

		if ( !len( json.id ) ) {
			messageId = "profile.created";
			thisId    = super.fire( "profile.create", [ profile ] )
		} else {
			messageId = "profile.updated";
			thisId    = super.fire( "profile.update", [ profile ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
        
        var result = super.getResult();
        var list = GetHTTPRequestData().content;
        var messageId = "profile.deletedAllRecords";

        var errors = [];
        var payload = "";

        var ids = ListToArray( list );

        for( var id in ids ) {
            var outcome = super.fire( "profile.delete", [ id ] );

            if( outcome.getStatus() == "ERROR"  ) {
                errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
            }

        }

        if( errors.len() ) {
            messageId = "profile.deletedNotAllRecords"
            payload = { "errors": errors } ;
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}	


}
