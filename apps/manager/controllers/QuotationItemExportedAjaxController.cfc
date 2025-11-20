component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		var rows = super.fire( "quotationItemExported.search", params );
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
		var key = rc.key;

		var rows = super.fire( "quotationItemExported.searchRows", { key = key } );
		var data = mem.convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result     = super.getResult();
		var validation = getValidationResult();

		var outcome = super.fire( "quotationItemExported.delete", { key = rc.key } );

		if ( outcome.getStatus() == "ERROR" ) {
			var error = super.getValidationError(
				message = getMessage( "quotationItemExported.notDeleted" ),
				field   = "general"
			);
			validation.addError( error );

			event.setValue( "result", validation );
			return;
		}

		result.setData( { "message" = getMessage( "quotationItemExported.deleted" ) } );

		event.setValue( "result", result );
	}

	function deleteMulti( event, rc, prc ){
		var result     = super.getResult();
		var validation = getValidationResult();

		var selected = rc.selected;

		transaction {
			for ( var key in selected ) {
				var outcome = super.fire( "quotationItemExported.delete", { key = key } );

				if ( outcome.getStatus() == "ERROR" ) {
					var error = super.getValidationError(
						message = getMessage( "quotationItemExported.notDeleted" ),
						field   = "general"
					);
					validation.addError( error );

					event.setValue( "result", validation );
					return;
				}
			}
		}

		result.setData( { "message" = getMessage( "quotationItemExported.deleted" ) } );

		event.setValue( "result", result );
	}

	function deleteRow( event, rc, prc ){
		var result     = super.getResult();
		var validation = getValidationResult();

		var outcome = super.fire( "quotationItemExported.deleteRow", { key = rc.key, rowNumber = rc.rowNumber } );

		if ( outcome.getStatus() == "ERROR" ) {
			var error = super.getValidationError(
				message = getMessage( "quotationItemExported.notDeleted" ),
				field   = "general"
			);
			validation.addError( error );

			event.setValue( "result", validation );
			return;
		}

		result.setData( { "message" = getMessage( "quotationItemExported.deleted" ) } );

		event.setValue( "result", result );
	}
}
