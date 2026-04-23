component extends="com.apirone.core.controller.AbsController" {
	function save( event, rc, prc ){
		var result = super.getResult();

		var texts     = [];

		var json = DeserializeJSON( GetHTTPRequestData().content );

		var positions = json.positions;

		transaction {
			try {
				for ( var pos in positions ) {
					var position = super.fire( "QuotationItemPosition.get", [ pos.id ] );
					position.setCoordinateX( pos.coordinateX );
					position.setCoordinateY( pos.coordinateY );
					position.setVisible( pos.visible );
					super.fire( "QuotationItemPosition.update", [ position ] );
				}
					result.setData( { "message" = "Salvataggio massivo posizioni completato." } );
					event.setValue( "result", result );
					return;
			} catch ( any e ) {
				transaction action="rollback";
				var message       = "Errore nel salvataggio massivo delle posizioni.";
				result.setData( { "error" = message } );
				result.setStatus( "ERRORE" );
				event.setValue( "result", result );
				return;
			}
		}
	}

}
