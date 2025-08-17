<script>

	function datamapperVsMementifier( event, rc, prc ){
		
		function runTest( engine="datamapper" ) {

			var svc = getContainer().getInstance("LineService");
			var dm = getContainer().getInstance("DataMapper");			

			var data = []
			var rows = svc.search( limit=500 );

			var start = GetTickCount();

			for ( row in rows.getData() ) {

				var obj = {};

				if( engine == "datamapper" ) {
					obj = dm.convert( row, "Line", true );
				} else {
					obj = row.getMemento(profile="list");

				}
				data.add( obj );
			}

			var end = GetTickCount();

			dump(data);

			return {
				"engine" = arguments.engine,
				"time" = end-start & " milliseconds",
				"count" = rows.getCount()
			}
			
		}

		var mem = {};
		var dat = {};

		var mem = runTest( engine="mementifier" );
		var dat = runTest( engine="datamapper" );

		prc.result = { "mementifier" = mem, "datamapper" = dat };

		dump( prc.result )
		abort;

		event.setView( "util/tmp" );
	}

</script>


/*

	dentro line.cfc ho messo
	this.memento = {
		defaultIncludes = [],
		defaultExcludes = [],
		neverInclude    = [],
		defaults        = {},
		mappers         = {},
		profiles        = {
			list   = { defaultIncludes = [ "id", "shortId", "name", "nameItem", "descriptionItem", "thickness.id", "status", "nameItem", "createdAt", "code" ] },
		},
		// Auto cast boolean strings to Java boolean
		autoCastBooleans = true
	}	

*/