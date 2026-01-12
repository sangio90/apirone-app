component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var params = super.paramsFromUrl();


		```
		<cfquery name="local.q" datasource="apirone">
			SELECT *
			FROM line_costs
			LIMIT <cfqueryparam value="#params.limit#" cfsqltype="Integer">
			OFFSET <cfqueryparam value="#params.offset#" cfsqltype="Integer">
		</cfquery>

		```

		var data = [];

		for( var record in local.q ){
			//var obj = mm.convert( record, "list" );

			var category = super.service("ProductCategory").get( record.product_category_id );
			var line     = super.service("Line").get( record.line_id );
			var finish   = super.service("Finish").get( record.finish_id );

			var row = {
				"id" = record.line_cost_id,
				"cost" = record.cost,
				"category"= {
					"id"  = category.getId(),
					"name" = category.getName()
				},
				"line"= {
					"id"  = line.getId(),
					"name" = line.getName()
				},
				"finish"= {
					"id"  = finish.getId(),
					"name" = finish.getName()
				}
			}

			data.append( row );
		}

		result.setTotal( local.q.recordcount );
		result.setCount( data.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId     = "";
		var messageId  = "";
		var categories = [];

		var result    = super.getResult();
		var line      = super.bean( "Line" );
		var status    = super.bean( "Status" );
		var thickness = super.bean( "Thickness" );
		var category  = super.bean( "ProductCategory" );

		for ( var thisCategory in json.selectedCategories ) {
			var category = super.bean( "ProductCategory" );

			category.setId( thisCategory.id )
			categories.add( category );
		}

		line.setId( json.id );
		line.setCode( json.code );
		line.setName( json.name );

		line.setStatus( status.setId( json.status.id ) );
		line.setCategories( categories );
		line.setThickness( thickness.setId( json?.thickness?.id ) );

		var nameItem        = super.buildTextBean( json.nameItem, "NAME" );
		var descriptionItem = super.buildTextBean( json.descriptionItem, "DESC" );

		line.setTexts( [ nameItem, descriptionItem ] );

		if ( !Len( json.id ) ) {
			messageId = "line.created";
			thisId    = super.fire( "line.create", [ line ] )
		} else {
			messageId = "line.updated";
			thisId    = super.fire( "line.update", [ line ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

}

