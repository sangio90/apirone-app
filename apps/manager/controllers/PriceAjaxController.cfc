component extends="com.apirone.core.controller.AbsController" {
	
	function reassign( event, rc, prc ){
		var result = super.getResult();
		var args = {};
	
		args[ rc.category ] = uCase( trim( rc.oldParam ) );
		args[ "paramCategory" ] = rc.category;
		args[ "newParam" ] = uCase( trim( rc.newParam ) );
		args[ "oldParam" ] = uCase( trim( rc.oldParam ) );

		transaction {
			try {
				var rowsCount = super.fire( "component.massiveReassign", args );
				var message = "";
				if (rowsCount == 0) {
					var message = "Non è stato modificato nessun componente.";
				}
				if (rowsCount == 1) {
					var message = "è stato modificato 1 componente.";
				}
				if (rowsCount > 1) {
					var message = "Sono stati modificati " & rowsCount & " componenti.";
				}
				result.setData( { "message" = message } );
				event.setValue( "result", result );
				return;
			} catch ( any e ) {
				transaction action="rollback";
				var message = "Errore nella riassegnazione massive dei componenti.";
				result.setData( { "error" = message } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
			}
		}
	}
	
	function massiveDelete( event, rc, prc ){
		var result = super.getResult();
		var args = {};
		args[ rc.category ] = uCase( trim( rc.oldParam ) );
		args[ 'paramCategory' ] = rc.category;
		args[ 'oldParam' ] = uCase( trim( rc.oldParam ) );

		transaction {
			try {
				var rowsCount = super.fire( "component.massiveDelete", args );
				var message = "";
				if (rowsCount == 0) {
					var message = "Non è stato cancellato nessun componente.";
				}
				if (rowsCount == 1) {
					var message = "è stato cancellato 1 componente.";
				}
				if (rowsCount > 1) {
					var message = "Sono stati cancellati " & rowsCount & " componenti.";
				}
				result.setData( { "message" = message } );
				event.setValue( "result", result );
				return;
			} catch ( any e ) {
				transaction action="rollback";
				var message = "Errore nella cancellazione massive dei componenti.";
				result.setData( { "error" = message } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
			}
		}
	}
	
}
