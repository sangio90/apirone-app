component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var rows = super.service("Product").search( processingTypeId="A" ).getData(); //materie prime

        dump( rows );

        event.renderData( data=rows, contentType="text/json", type="json" );
        
    }

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "productCategory.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

}
