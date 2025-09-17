component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mem     = super.getMementify();

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

}
