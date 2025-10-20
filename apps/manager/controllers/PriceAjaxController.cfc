component extends="com.apirone.core.controller.AbsController" {

	function calculate( event, rc, prc ){
		var result = super.getResult();

        var items = [
            {
                label = "Calcolo componenti base",
                cost = RandRange( 1, 5) 
            },
            {
                label = "Calcolo componenti dell'albero",
                cost = RandRange( 1, 5)
            },
            {
                label = "SPESSORE 2,5MM",
                cost = RandRange( 1, 5)
            },
            {
                label = "BRAILLE: SI",
                cost = RandRange( 1, 7)
            },
            {
                label = "PERNO 10MM",
                cost = RandRange( 1, 8 )
            },
        ];

        var description = "";
        var total = 0;

        for( var item in items ) {

            description = "#description# #item.label#: #NumberFormat( item.cost, '0.00')# EUR<br>"
            total = total + Val( item.cost );

        }

		var output = { "total" = total, "description" = description }

		result.setData( output );

		event.setValue( "result", result );
	}

	function calculateQuotationItem( event, rc, prc ){
		var params          = {};
		var data            = [];
		var result          = super.getResult();
		var mm              = super.getMementify();
		var quotationItemId = rc.id;

		var output = {
			"id"       = quotationItemId,
			"products" = [
				{
					"id"     = "ART",
					"label"  = "Prezzo articolo",
					"amount" = 31.7
				},
				{ "id" = "P1", "label" = "Riga 1", "amount" = 3.5 },
				{ "id" = "P2", "label" = "Riga 2", "amount" = 4.6 },
				{ "id" = "P2", "label" = "Riga 3", "amount" = 5.7 }
			],
			"quantity" = { "label" = "Quantità prodotti", "count" = 3 },
			"total"    = { "label" = "TOTALE", "amount" = 45.50 }
		}

		result.setData( output );

		event.setValue( "result", result );
	}

	function calculateQuotation( event, rc, prc ){
		var params      = {}
		var data        = [];
		var result      = super.getResult();
		var mm          = super.getMementify();
		var quotationId = rc.id;

		var output = {
			"id"       = quotationId,
			"quantity" = { "label" = "Numero prodotti", "count" = 4 },
			"total"    = { "label" = "TOTALE", "amount" = 45.50 }
		};

		result.setData( output );

		event.setValue( "result", output );
	}


	function list( event, rc, prc ){
		var params = {}
		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var entity;

		if ( rc.by == "products" ) {
			params[ "productId" ] = rc.id;
			entity                = "PRODUCT";
		}

		if ( rc.by == "product-items" ) {
			params[ "productItemId" ] = rc.id;
			entity                    = "PRODUCT_ITEM";
		}


		var allTypes = super.fire( "priceType.list", { entityId = entity } );

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
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		var messageId = "prices.updated";

		var key   = "";
		var value = "";

		if ( rc.by == "products" ) {
			key   = "product.id";
			value = json.item.id;
		}

		if ( rc.by == "product-items" ) {
			key   = "productItem.id";
			value = json.item.id;
		}

		if ( key == "" ) {
			Throw(
				type    = "apirone.error.component.InvalidEntityType",
				message = "You must specify the entity for which the price is saved."
			);
		}

		for ( var item in json.prices ) {
			var price  = super.bean( "Price" );
			var method = super.bean( "PriceMethod" );
			var entity = super.bean( "Entity" );

			price.setId( item?.id );
			price.setAmount( item.amount );
			price.setMethod( method.setId( item.method.id ) );
			price.setEntity( entity.setKey( key ).setValue( value ) );

			if ( Len( item?.id ) ) {
				super.fire( "price.update", [ price ] );
			} else {
				var type = super.bean( "PriceType" );

				price.setType( type.setId( item.type.id ) );

				super.fire( "price.create", [ price ] );
			}
		}

		var message = completeMessage( messageId );
		result.setData( { "message" = message } );

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
