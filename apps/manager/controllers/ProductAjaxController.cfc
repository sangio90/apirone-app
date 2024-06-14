component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var rows = super.service("Product").search( processingTypeId="A" ).getData(); //materie prime

        dump( rows );

        event.renderData( data=rows, contentType="text/json", type="json" );
        
    }

}
