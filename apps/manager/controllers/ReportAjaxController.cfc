component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var memy   = super.getMementify();

		var rows = super.fire( "report.search" ).getData();

		for ( var row in rows ) {
			var obj = memy.convert( row, "list" );
			data.add( obj );
		}

		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

}
