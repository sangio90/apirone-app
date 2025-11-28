component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="productService" inject="ProductService";
	property name="productItemService" inject="ProductItemService";
	property name="componentService" inject="ComponentService";
	// property name="priceTypeService" inject="PriceTypeService";

	variables.logConfig = {};
	variables.costs     = [];

	public Numeric function calculate(
		required String productId,
		required Numeric quantity = 1,
		Array producItemtIds
	){
		var price = simulate( argumentCollection = arguments );
		return price.values.finalPrice;
	}

	public Struct function simulate(
		required String productId,
		required Numeric quantity = 1,
		Array producItemtIds
	){
		if ( arguments.quantity LTE 0 ) {
			Throw(
				type    = "apirone.error.PriceCalculator.QuantityLessThenZero",
				message = "The quantity [#arguments.quantity#] must be greater than zero."
			);
		}

		/*
			INFO:

			c1 = totale costi comp. bundle
			c2 = totale costi comp. articolo
			s1 = ( c1+c2 ) * markup articolo (PRICE);

			sN = per ogni productItem
					totale costi dei componenti
						* marktup attr generale (PROD_ITEM_GEN) o quello specifico (PROD_ITEM_PRICE)

			sT = totale costi productItems (somma sN)

			costo finale  = c1 + c2 + costo fisso;
			prezzo finale = s1 + sT + costo fisso;
		*/

		var total  = 0;
		var cost   = 0;
		var markup = 0;
		var method = 0;
		var costs  = [];

		var itemsComponents = {};

		var productSvc   = getProductService();
		var componentSvc = getComponentService();

		var productId      = arguments.productId;
		var productItemIds = arguments.producItemtIds;

		var product = productSvc.get( productId );
		var price   = product.getPrice( "PRICE" );

		var name = "#product.getDescription()# (#product.getCode()#)";

		var isFixedPrice = ( price.getMethod().getId() == "F" );
		var markup = price?.getAmount() ?: 0;

		appendLog(
			message   = "Inizio calcolo del prezzo per #name#, quantità: #arguments.quantity#. Prezzo: fisso: #isFixedPrice#, valore: #markup#",
			productId = product.getSerial()
		);

		
		/*
			fixed cost
		*/

		var fixedCost     = product.getPrice( "COST_FIXED" )?.getAmount() ?: 0;
		var unitFixedCost = fixedCost / arguments.quantity;

		appendLog(
			message = "Costo fisso per #arguments.quantity# pezzi. Costo fisso #fixedCost# / #arguments.quantity#;Costo fisso unitario: #formatExtended( unitFixedCost )#"
		);

		addCost( "Costo fisso", unitFixedCost, "P" ); // sommerò gli "P" per il costo finale


		/*
			cost bundle
		*/

		var bundleCost = 0;

		if ( IsInstanceOf( product, "com.apirone.core.model.bean.ProductComplex" ) ) {
			var bundleComponents = componentSvc.list(
				lineId                         = product.getLine().getId(),
				modelId                        = product.getModel().getId(),
				includeBaseAttributeComponents = true
			);

			var bundleCost = calculateComponentsTotal( bundleComponents );
		}

		// il log viene scritto da in calculateComponentsTotal()
		// appendLog( "Costo componenti per bundle;Totale attributi: #formatExtended( bundleCost )#" );

		addCost(
			"Costo componenti linea / modello",
			bundleCost,
			"P"
		);


		/*
			cost base product
		*/

		var productComponents = componentSvc.list( productId = productId, includeBaseAttributeComponents = true );

		var productCost = calculateComponentsTotal( productComponents );

		// appendLog( message = "Costo componenti prodotto #productComponents#;Totale unitario: #formatExtended( productCost )#" );

		addCost( "Costo componenti prodotto", productCost, "P" );


		/*
			cost items
		*/

		var attributePrice = product.getPrice( "PROD_ITEM_GEN" );

		appendLog( "** Inizio del calcolo del prezzo degli attributi" );

		for ( var itemId in productItemIds ) {
			var itemComponents = componentSvc.list( productItemId = itemId, includeBaseAttributeComponents = true );

			var itemCost = 0;
			var compCost = 0;

			var productItem = getProductItemService().get( itemId );

			var attributeName = "Item: #itemId#, Attributo: #productItem.getAttribute().getName()# / #productItem
				.getAttributeValue()
				.getRawValue()
				.getName()#";

			var productItemPrice = productItem.getPrice( "PROD_ITEM_PRICE" );

			if ( !IsNull( productItemPrice ) ) {
				var amount = productItemPrice.getAmount() ?: 0;

				if ( productItemPrice.getMethod().getId() == "F" ) {
					appendLog(
						message = "#attributeName#. Prezzo -fisso- per questo attributo: #productItemPrice.getAmount()#. Salto i costi dei componenti;Costo attributo: #formatExtended( amount )#"
					);

					itemCost = amount;
				} else if ( productItemPrice.getMethod().getId() == "M" ) {
					var compCost = calculateComponentsTotal( itemComponents );
					itemCost     = compCost * productItemPrice.getAmount();

					appendLog(
						message = "#attributeName#. Markup per questo attributo: #productItemPrice.getAmount()#. Totale componenti: #compCost# * markup: #productItemPrice.getAmount()#;Costo attributo: #formatExtended( itemCost )#"
					);
				}
			} else {
				if ( !IsNull( attributePrice ) ) {
					compCost = calculateComponentsTotal( itemComponents );

					var amount = attributePrice.getAmount() ?: 0;

					itemCost = compCost * amount;

					appendLog(
						message = "Markup generale per questo attributo: #productItem.getId()#. Totale componenti: #compCost# * markup: #amount#;Costo attributo: #formatExtended( itemCost )#"
					);
				}
			}

			addCost( "Costo attributo #itemId#", itemCost, "I" );
		}

		appendLog( "** Fine del calcolo del prezzo degli attributi; Totale attributi: #formatExtended( calculateTotalCostItems() )#" );


		/*
			final cost
		*/

		var finalCost = bundleCost + productCost + unitFixedCost;

		appendLog(
			message    = "Costi finali. Bundle: #bundleCost# + prodotto base: #productCost# + costo fisso: #unitFixedCost#;Costo finale: #formatExtended( finalCost )#",
			lineTypeId = "H"
		);

		/*
			final price
		*/

		var totalCostItems = calculateTotalCostItems();


		// appendLog( message = " ;Totale costi prodotto: #formatExtended( costProduct )#" );

		if( isFixedPrice ) {

			var finalPrice =  ( bundleCost + productCost + totalCostItems + unitFixedCost ) + markup;

			appendLog(
				message    = "Prezzo finale fisso. ( Bundle: #bundleCost# + prodotto base: #productCost# + prezzo items: #totalCostItems# + costo fisso: #unitFixedCost# ) + markup fisso: #markup#;Prezzo finale: #formatExtended( finalPrice )#",
				lineTypeId = "H"
			);

		} else {

			var finalPrice = ( ( bundleCost + productCost ) * markup ) + totalCostItems + unitFixedCost;

			appendLog(
				message    = "Prezzo finale. ( Bundle: #bundleCost# + prodotto base: #productCost# ) * markup: #markup# ) + prezzo items: #totalCostItems# + costo fisso: #unitFixedCost#;Prezzo finale: #formatExtended( finalPrice )#",
				lineTypeId = "H"
			);

		}



		var output = {
			values = {
				"finalCost"      = finalCost,
				"bundleCost"     = bundleCost,
				"productCost"    = productCost,
				"totalCostItems" = totalCostItems,
				"unitFixedCost"  = unitFixedCost,
				"finalPrice"     = finalPrice,
				"priceType"      = price
			},
			"logFile" = variables.logConfig.filePath
		};

		return output;
	}


	/*
		private methods
	*/

	private Numeric function calculateComponentsTotal( Array components, Struct price ){
		var total = 0;
		var log   = "";

		if ( !Len( components ) ) {
			return 0
		}

		var compType = ListLast(
			Replace(
				GetComponentMetadata( components[ 1 ] ).name,
				"Component",
				""
			),
			"."
		);

		appendLog( "* Inizio del calcolo del costo dei componenti #compType#" );

		for ( var component in components ) {
			var name = "Componente: #component.getId()# - articolo: #component.getRawProduct().getId()# variante: #component.getVariant().getId()# colore: #component.getColor().getId()#";

			if ( !component.isDeleted() ) {
				var amount = component.getCost().getAmount();

				var quantity = component.getTotalQuantity(); // with override

				var rowTotal = amount * quantity;

				total = total + rowTotal;

				appendLog( "#name# - costo unitario: #amount# * quantità: #quantity#; Costo compon.: #formatExtended( rowTotal )#" );
			} else {
				appendLog( "#name#;CANCELLATO" );
			}
		}

		appendLog( "* Fine del calcolo del costo dei componenti #compType#;Totale compon.: #formatExtended( total )#" );

		return total;
	}

	private Void function addCost(
		required String label,
		required Numeric amount,
		required String typeId = "P"
	){
		variables.costs.add( {
			"label"  = arguments.label,
			"amount" = arguments.amount,
			"typeId" = arguments.typeId
		} );
	}

	private Void function appendLog(
		required String message,
		String productId,
		String lineTypeId
	){
		var allowedLineType = "N,H"; // N=normal, H=highlighted

		if ( IsNull( arguments.lineTypeId ) ) {
			arguments.lineTypeId = "N" // normal
		}

		if ( !ListFind( allowedLineType, arguments.lineTypeId ) ) {
			Throw(
				type    = "apirone.error.PriceCalculator.LineTypeIdNotAllowed",
				message = "Only this line types is allowed: #allowedLineType#"
			)
		}

		if ( ListLen( message, ";" ) GT 2 ) {
			Throw(
				type    = "apirone.error.PriceCalculator.messageHasTooManyFields",
				message = "The log message can only have 2 fields (separated by ';')"
			)
		}

		if ( StructIsEmpty( variables.logConfig ) ) {
			if ( IsNull( productId ) ) {
				Throw(
					type    = "apirone.error.PriceCalculator.productIdRequired",
					message = "ProductId is required on the first invocation of appendLog()"
				)
			}

			startLog( productId );
		}

		var thisDate = DateTimeFormat( Now(), "yyyy-mm-dd HH:nn:ss" );

		var line = "#thisDate#;#arguments.lineTypeId#;#variables.logConfig.productId#;#message##Chr( 10 )#";

		FileAppend( variables.logConfig.filePath, line );
	}

	private Struct function startLog( required String productId ){
		var util = new com.apirone.core.util.Udf();
		// var name = util.prettyString( productName );

		var logsDir = ExpandPath( "/../repository/private/logs/prices" );

		if ( NOT DirectoryExists( logsDir ) ) {
			DirectoryCreate( logsDir, true );
		}

		var fileName = "product_"
		& DateTimeFormat( Now(), "yyyy-mm-dd_HH-nn-ss" )
		& "_serial-" & productId & ".log";

		if ( request.isDev() ) {
			fileName = "product_price_development_" & DateFormat( Now(), "yyyy-mm-dd" ) & ".log"
		}

		var filePath = logsDir & "/" & fileName;

		FileWrite( filePath, "", "UTF-8" );

		variables.logConfig = { filePath = filePath, productId = productId };

		return logConfig;
	}

	private Numeric function calculateTotalCostItems(){
		var total = 0;

		for ( var item in variables.costs ) {
			if ( item.typeId EQ "I" ) {
				total = total + item.amount
			}
		}

		return total;
	}

	private Numeric function formatExtended( required Numeric value ){
		return NumberFormat( value, ".9999" );
	}

}
