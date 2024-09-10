component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.str = "";

        // processingTypeId="A" -> materie prime
        var rows = super.service("Component").search( processingTypeId="A", str="#rc.str#" ); //materie prime

        //TODO: use postEvent for formatting
        event.renderData( data=rows, contentType="text/json", type="json" );
        
    }

}
