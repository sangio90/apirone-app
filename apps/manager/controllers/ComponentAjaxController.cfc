component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.str = "";

        // processingTypeId="A" -> materie prime
        //materie prime
        var rows = super.fire("component.search", { processingTypeId="A", str="#rc.str#", limit=15 } ); /

        event.setValue("result", rows.getData());
        
    }

}
