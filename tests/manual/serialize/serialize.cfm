<cfscript>

	container = server["wirebox-apirone"];
	
	function runTest( engine="datamapper" ) {


		var svc = container.getInstance("LineService");
		var dm = container.getInstance("DataMapper");			

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

		return {
			"engine" = arguments.engine,
			"time" = end-start & " milliseconds",
			"count" = rows.getCount()
		}
		
	}

	mem = {};
	dat = {};

	mem = runTest( engine="mementifier" );
	//dat = runTest( engine="datamapper" );

	result = { "mementifier" = mem, "datamapper" = dat };

	dump( result );

	abort;

</cfscript>
