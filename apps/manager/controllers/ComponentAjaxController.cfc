component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.str = "";
       
        var result = super.getResult();
        var params = super.paramsFromUrl();

        var rows = super.fire("component.search", params ); 

        result.setTotal( rows.getTotal() )
        result.setCount( rows.getCount() )
        result.setData( rows.getData() )

        event.setValue("result",  result );
        
    }

}
