component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.str = "";

        // processingTypeId="A" -> materie prime
        var rows = super.service("Component").search( processingTypeId="A", str="#rc.str#" ); //materie prime

        event.setValue("result", rows.getData());
        
    }

}
