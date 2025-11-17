component extends="com.apirone.core.controller.AbsController" {

	function simulate( event, rc, prc ){
		var result = super.service( "PriceCalculator" ).simulate( rc.id, rc.quantity, ListToArray( rc.itemIds ) );

		var description = prepareDescription( result.logFile );

		var output = {
			"price"       = result.values.finalPrice,
			"description" = description
		}

		event.setValue( "result", output );
	}

	function calculateQuotationItem( event, rc, prc ){
		var result     = super.getResult();
		var memy       = super.getMementify();
		var calculator = super.service( "PriceCalculator" );
		var pricing    = super.bean( "QuotationPrice" );

		var totalGoods = 0;

		var json = DeserializeJSON( GetHTTPRequestData().content );

		/*
			plate price
		*/

		var productItemsIds = [];

		for ( var item in json.product.items._data ) {
			for ( var value in item.values ) {
				if ( value.selected ) {
					productItemsIds.add( value.productItemId );
				}
			}
		}

		var platePrice = calculator.calculate(
			json.product.id,
			json.quantity,
			productItemsIds
		);

		dump( platePrice );
		abort;

		var line = super.bean( "PriceItem" );

		line.setName( "Prezzo placca" );
		line.setAmount( platePrice.getFinalPrice() );

		lines.add( line );


		/*
			fruits price
		*/

		var fruitsLines = [];

		for ( var fruit in json.fruits_data ) {
			var fruitItemsIds = [];
			var line          = super.bean( "PriceItem" );

			for ( var item in fruit.items._data ) {
				for ( var value in item.values ) {
					if ( value.selected ) {
						fruitItemsIds.add( value.productItemId );
					}
				}
			}

			var fruitPrice = super.service( "PriceCalculator" ).simulate( fruit.id, 1, fruitItemsIds );

			line.setName( "Prezzo #fruit.name#" );
			line.setAmount( fruitPrice.getFinalPrice() );

			totalGoods = totalGoods + fruitPrice.getFinalPrice();

			fruitsLines.add( line );
		}

		fruitsLines.menge( lines );

		quotationPrice.setItems( fruitsLines );

		result.setData( quotationPrice );

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

		for ( var item in output ) {
			var row          = mm.convert( item );
			row[ "deleted" ] = false;
			data.add( row );
		}

		result.setTotal( data.len() );
		result.setCount( data.len() );
		result.setData( data );

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
				type    = "apirone.error.price.InvalidEntityType",
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
				// var obj = get( item.id );
				// price.setEntity( obj.getEntity() );

				if ( item.deleted ) {
					super.fire( "price.delete", [ item.id ] );
				} else {
					super.fire( "price.update", [ price ] );
				}
			} else {
				if ( Len( item.amount ) ) {
					var type = super.bean( "PriceType" );
					price.setType( type.setId( item.type.id ) );
					super.fire( "price.create", [ price ] );
				}
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

	/*
		private methods
	*/

	private String function prepareDescription( logFile ){
		// Toglie le prime tre parti della riga: data e nome del prodotto

		var result = "<table class='price-log-table'>";
		var count  = 1;

		loop file=logFile item="line" {
			var parts = ListToArray( line, ";" );

			var td1 = parts.indexExists( 4 ) ? parts[ 4 ] : ""; // penultimate
			var td2 = parts.indexExists( 5 ) ? parts[ 5 ] : ""; // last

			var trClass = parts.indexExists( 2 ) AND parts[ 2 ] == "H" ? "price-log-table-tr-highlight" : "";

			result = result
			& "<tr class='#trClass#'>
					<td width='25' class='text-end'>#count#</td>
					<td>#td1#</td>
					<td width='200' class='text-end'><b>#td2#</b></td>
				</tr>";

			count++;
		}

		return result & "</table>";
	}

}
