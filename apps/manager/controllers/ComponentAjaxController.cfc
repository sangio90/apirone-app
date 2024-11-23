component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.str = "";

        var result = super.getResult();

        var args = super.paramsFromUrl()
        args.limit = 15;


        // processingTypeId="A" -> materie prime
        //materie prime
        var rows = super.fire("component.search", { processingTypeId="A", str="#rc.str#", limit=15 } ); 

        result.setTotal( rows.getTotal() )
        result.setCount( rows.getCount() )
        result.setData( rows.getData() )

        event.setValue("result",  result );
        
    }

}
