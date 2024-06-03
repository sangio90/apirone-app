component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = arguments.event.getValue( "DataMapper" );
        var user = prc.user;
        
        param name="url['sort[0][field]']" default="name";
        param name="url['sort[0][dir]']" default="asc";
        
        var user = prc.user;

        var field = url['sort[0][field]'] == 'name' ? 'email' : '';
        var sort = url['sort[0][dir]'];
        
        var rows = getAccessManager().exec( 
                    user, 
                    "quotation.search", 
                    { orderBy = [ { 'field' = field, 'sort' = sort }]  } 
                ).getData();

        for ( var row in rows ) {

            var obj = dm.convert( row, "Account", true );
            data.add( obj );

        }

        result.setTotal( data.len() );
        result.setData( data );

        event.renderData( data=result, contentType="text/json", type="json" );
        
    }

}
