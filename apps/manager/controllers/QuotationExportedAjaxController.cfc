component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		var rows = super.fire( "quotationExported.search", params );
		var data = mem.convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function listRows( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		var rows = super.fire( "quotationExported.searchRows", { quotationSerial = rc.quotationSerial } );
		var data = mem.convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result     = super.getResult();
		var validation = getValidationResult();

		var outcome = super.fire( "quotationExported.delete", { quotationSerial = rc.quotationSerial } );

		if ( outcome.getStatus() == "ERROR" ) {
			var error = super.getValidationError(
				message = getMessage( "quotationExported.notDeleted" ),
				field   = "general"
			);
			validation.addError( error );

			event.setValue( "result", validation );
			return;
		}

		result.setData( { "message" = getMessage( "quotationExported.deleted" ) } );

		event.setValue( "result", result );
	}

	function deleteMulti( event, rc, prc ){
		var result     = super.getResult();
		var validation = getValidationResult();

		var selected = rc.selected;

		transaction {
			for ( var quotationSerial in selected ) {
				var outcome = super.fire( "quotationExported.delete", { quotationSerial = quotationSerial } );

				if ( outcome.getStatus() == "ERROR" ) {
					var error = super.getValidationError(
						message = getMessage( "quotationExported.notDeleted" ),
						field   = "general"
					);
					validation.addError( error );

					event.setValue( "result", validation );
					return;
				}
			}
		}

		result.setData( { "message" = getMessage( "quotationExported.deleted" ) } );

		event.setValue( "result", result );
	}

	function deleteRow( event, rc, prc ){
		var result     = super.getResult();
		var validation = getValidationResult();

		var outcome = super.fire( "quotationExported.deleteRow", { key = rc.quotationSerial, rowNumber = rc.rowNumber } );

		if ( outcome.getStatus() == "ERROR" ) {
			var error = super.getValidationError(
				message = getMessage( "quotationExported.notDeleted" ),
				field   = "general"
			);
			validation.addError( error );

			event.setValue( "result", validation );
			return;
		}

		result.setData( { "message" = getMessage( "quotationExported.deleted" ) } );

		event.setValue( "result", result );
	}
}
