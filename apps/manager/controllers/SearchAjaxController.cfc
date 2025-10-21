component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		param rc.str = "";

		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var params = { limit = 20, str = rc.str }

		var rows = super.fire( "search.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.append( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

}
