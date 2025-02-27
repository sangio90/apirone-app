component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.str = "";
       
        var result = super.getResult();
        var params = super.paramsFromUrl( "rawProduct" );

        var rows = super.fire("rawProduct.search", params ); 

        result.setTotal( rows.getTotal() );
        result.setCount( rows.getCount() );
        result.setData( rows.getData() );

        event.setValue( "result",  result );
        
    }

}
