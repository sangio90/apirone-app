component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mem    = super.getMementify();

		var params = super.paramsFromUrl();

		var rows = super.fire( "catalogBundle.search", params );

		for ( var row in rows.getData() ) {
			var obj = mem.convert( row, "list" );
			data.append( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		param rc.id = "___";
		var result  = super.getResult();

		if ( !super.isUuid( rc.id ) ) {
			return event.setValue( "result", "No UUID" );
		}

		var bean = super.fire( "catalogBundle.get", [ rc.id ] );

		var obj = super.getMementify().convert( bean, "list" );

		if ( !obj.keyExists( "thickness" ) ) {
			obj[ "thickness" ] = { "id" = "", "name" = "" }
		}

		result.setData( obj );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result    = super.getResult();
		var mem       = super.getMementify();
		var messageId = "catalogBundle.updated";

		var content = GetHTTPRequestData().content;
		var data    = DeserializeJSON( content )

		var errors  = [];
		var payload = {};

		for ( var item in data._data ) {
			if ( item.keyExists( "markupValue" ) AND Len( item.markupValue ) ) {
				if ( IsNumeric( item.markupValue ) ) {
					var bean = super.bean( "CatalogBundle" );

					bean.setId( item.id );
					bean.setMarkupValue( item.markupValue )

					super.fire( "catalogBundle.update", [ bean ] )
				} else {
					errors.add( {
						"message" = "Non sono riuscito ad aggiornare l'Id #item.id#"
					} )
				}
			}
		}

		if ( errors.len() ) {
			messageId = "catalogBundle.updatedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
