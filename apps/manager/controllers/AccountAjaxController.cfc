component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = super.getDataMapper()

        var args = paramsFromUrl()
        
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

        param name="rc.id" default="___";
        var result = super.getResult();

        var obj = getAccessManager()
                .exec( 
                    prc.user, 
                    "Account.get", 
                    [ rc.id ]
                );

        result.setData( IsNull( obj ) ? false : true );

        event.setValue("result", result);
        
    }

   
    function save( event, rc, prc ){

        var user = prc.user;
        var result = super.getResult();

        var raw    = GetHTTPRequestData().content;
        var json   = DESerializeJSON( raw );

        if ( json.action == "create" ) {

            var actionLog = "OPTION_CREATED";
            var method = "Account.update";
            var bean = super.bean( "Option" );
            var price = super.bean( "Price" );
            price.setType( super.bean( "PriceType" ) );
            bean.setPrice( price );

        } else {

            var actionLog = "OPTION_UPDATED";
            var method = "Account.update";
            var bean = getAccessManager().exec( user, "Account.get", [ json.data.id ] );

        }

        bean.setName( json.data.name );
        bean.setQuantity( Val( json.data.quantity ) );
        bean.getPrice().setValue( json.data.price.value );
        bean.getPrice().getType().setId( json.data.price.type.id );

        bean.setTypes( [] );

        var beanTypes = []

        if ( StructKeyExists( json, "selectedTypes" ) ) {
            for ( var type in json.selectedTypes ) {

                var shipType = super.bean( "ShipmentType" );
                
                beanTypes.add( 
                    shipType.setId( type ) 
                );

            }
        } 

        bean.setTypes( beanTypes );

        var id = getAccessManager().exec( user, method, [ bean ] );

        result.setData( { "action" = actionLog, "id": id } );

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
