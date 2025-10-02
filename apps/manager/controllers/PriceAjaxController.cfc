component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var params = {}

		if ( rc.by == "products" ) {
			params[ "productId" ] = rc.id;
		}

		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var allTypes = super.fire( "priceType.list", { entityId = "PRODUCT" } );

		var rows = super.fire( "price.list", { argumentCollection = params } );


		// INFO: ensure all types are present
		// 		even those with no price assigned yet
		// 		by creating empty price entries

		var output = []

		for ( var type in allTypes ) {
			var found = false;

			for ( var row in rows ) {
				if ( row.getType().getId() EQ type.getId() ) {
					found = true;
					output.append( row );
					break;
				}
			}

			if ( !found ) {
				var empyPrice = super.bean( "Price" );

				empyPrice.setType( type );
				empyPrice.setAmount( 0 );
				empyPrice.setMethod( super.fire( "lookup.get", { "entity" = "priceMethod", value = "F" } ) );

				output.append( empyPrice );
			}
		}

		var output = mm.convertList( output );

		result.setTotal( output.len() );
		result.setCount( output.len() );
		result.setData( output );

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


	function reassign( event, rc, prc ){
		var result = super.getResult();
		var args   = {};

		var messageId = "price.reassigned";

		for ( var key in rc ) {
			if ( Len( rc[ key ] ) ) {
				// only non empty
				args[ key ] = rc[ key ];
			}
		}

		var outout = super.fire( "price.massiveReassign", { argumentCollection = args } );

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = outout } );

		event.setValue( "result", result );
	}

}
