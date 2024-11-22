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

    
    function saveAll( event, rc, prc ){
        
        var user = prc.user;
        var result = super.getResult();
        var ids = [];

        var raw  = GetHTTPRequestData().content;
        var data = DESerializeJSON( raw );

        for ( var row in data ) {

            var bean = getAccessManager().exec( user, "Account.get", [ row.id ] );

            bean.setEmail( row.email );
            bean.getRole.setId( row.role.id );

            var id = getAccessManager().exec( user, "Account.update", [ bean ] );

            ids.add( id );

        }

        result.setTotal( data.len() );
        result.setCount( data.len() );
        result.setData( { "action": 'ACCOUNTS_SAVED', "ids": ids } );

        event.setValue("result", result);

    }

    function removeAll( event, rc, prc ){

        param name="selected" default="";
        
        var user = prc.user;
        var result = super.getResult();
        var ids = [];

        for ( var row in selected ) {

            var id = getAccessManager()
                .exec( 
                    user, 
                    "Account.delete",
                    [ row ]
                );

            ids.add( row );

        }

        result.setTotal( ids.len() );
        result.setCount( ids.len() );
        result.setData( { "action": 'ACCOUNTS_DELETED', "ids": ids } );

        event.renderData( data=result, contentType="text/json", type="json" );

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

}
