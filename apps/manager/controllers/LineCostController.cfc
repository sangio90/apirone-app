component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		prc.title = "Costi per linea/finitura";

		prc.categories = super.fire( "ProductCategory.list" );
		prc.lines      = super.fire( "Line.list" );
		prc.finishes   = super.fire( "Finish.list" );

		prc.jsFiles.add( "app-line-cost" );

		event.setView( "line/cost/list" );
	}

	function add( event, rc, prc ){

		```
		<cfset var error = false>

		<cftry>
			<cfquery name="local.q" datasource="apirone">
				INSERT INTO line_costs
					( product_category_id, line_id, finish_id, cost )
				VALUES
				( 
					<cfqueryparam value="#rc.categoryId#" cfsqltype="other">,
					<cfqueryparam value="#rc.lineId#" cfsqltype="other">,
					<cfqueryparam value="#rc.finishId#" cfsqltype="other">,
					<cfqueryparam value="#rc.cost#" cfsqltype="decimal"> 
				)
			</cfquery>
			<cfcatch>
				<cfset error = true>
			</cfcatch>
		</cftry>

		```

		if( error ){
			super.setMessage( "Costo esistente.", "error" );
			
		} else {
			super.setMessage( "Costo salvato con successo.", "success" );
		}

		relocate(
			uri               = "/manager/lines/costs",
			postProcessExempt = false,
			addToken          = false
		);

	}

	function save( event, rc, prc ){

		for( var field in rc.fieldnames ){

			if ( left( field, 5 ) EQ "cost_" ){

				var id = mid( field, 6 );

				```
				<cfquery name="local.q" datasource="apirone">
					UPDATE line_costs
					SET cost = <cfqueryparam value="#rc[ field ]#" cfsqltype="decimal">
					WHERE line_cost_id = <cfqueryparam value="#id#" cfsqltype="integer">
				</cfquery>
				```

			}

		}

		super.setMessage( "Costi aggiornati con successo.", "success" );

		relocate(
			uri               = "/manager/lines/costs",
			postProcessExempt = false,
			addToken          = false
		);

	}
}
