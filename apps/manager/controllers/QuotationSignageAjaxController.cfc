component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		var rows = super.fire(
			"signageConfig.list",
			{
				categoryId = rc.categoryId,
				lineId     = rc.lineId,
				modelId    = rc.modelId
			}
		);

		var data = mem.convertList( rows, "list" );

		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function deleteRow( event, rc, prc ){
		var result = super.getResult();
        var messageId = "quotationItemSignageRow.deleted";

        var errors = [];
        var payload = "";

        var id = rc.id

		var row = super.fire( 'quotationItemSignageRow.get', { quotationItemSignageRowId: id } );
		var outcome = super.fire( "quotationItemSignageRow.delete", [ id ] );

		if( outcome.getStatus() == "ERROR"  ) {
			errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
		}

        if( errors.len() ) {
            payload = { "errors": errors } ;
        }

        var message = super.completeMessage( messageId );

        result.setData( { "message" = message, "payload" =  payload } );
        
		event.setValue( "result", result );
	}

}
