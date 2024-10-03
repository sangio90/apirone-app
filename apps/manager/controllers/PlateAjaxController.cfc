component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();
        
        var rows = super.fire( "line.list" );

        for ( var row in rows ) {
            var obj = dm.convert( row, "Line", true );
            data.add( obj );
        }

        result.setTotal( data.len() );
        result.setData( data );

        event.renderData( data=result, contentType="text/json", type="json" );
        
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

  

}
