component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="productService" inject="ProductService";
	property name="productItemService" inject="ProductItemService";
	property name="ComponentService" inject="ComponentService";
	property name="priceTypeService" inject="PriceTypeService";

	variables.logConfig = {};
	variables.costs     = [];

	public Numeric function calculate( required String productId, Array producItemtIds ){
		return simulate( argumentCollection = arguments ).price;
	}

	public Struct function simulate( required String productId, Array producItemtIds ){
		/*
			c1 = totale costi comp. bundle
			c2 = totale costi comp. articolo
			s1 = ( c1+c2 ) * markup articolo (PRICE);

			sN = per ogni productItem
					totale costi dei componenti
						* marktup attr generale (PROD_ITEM_GEN) o quello specifico (PROD_ITEM_PRICE)

			sN = totale costi productItems

			costo finale  = c1 + c2 + costo fisso;
			prezzo finale = s1 + sN + costo fisso;
		*/

		var total  = 0;
		var cost   = 0;
		var markup = 0;
		var costs  = [];

		var itemsComponents = {};

		var productSvc   = getProductService();
		var componentSvc = getComponentService();

		var productId      = arguments.productId;
		var productItemIds = arguments.producItemtIds;

		var product   = productSvc.get( productId );
		var price     = product.getPrice( "PRICE" );
		var priceAttr = product.getPrice( "PROD_ITEM_GEN" );

		var name = "#product.getLine().getName()# / #product.getModel().getName()# / #product.getFinish().getName()#";

		appendLog( message = "Inizio calcolo del prezzo per #name#.", productName = "#name#" );

		/*

		*/

		if ( IsNull( price ) ) {
			appendLog( message = "Nessun prezzo caricato, imposto il markup a 1" );

			markup = 1
		} else {
			if ( price.getMethod().getId() == "F" ) {
				appendLog(
					message = "Caricato un prezzo fisso: #price.getAmount()#. Fine.;Totale prezzo: #formatExtended( price.getAmount() )#"
				);
				return var output = {
					"price"   = price.getAmount(),
					"logFile" = variables.logConfig.filePath
				};
			}
		}

		var markup = price?.getAmount() ?: 0;

		/*
			fixed cost
		*/

		var fixedCost = product.getPrice( "COST_FIXED" )?.getAmount() ?: 0;

		appendLog( message = "Applico costo fisso;Totale: #formatExtended( fixedCost )#", productName = "#name#" );

		// addCost( "Costo fisso", fixedCost );


		/*
			cost bundle
		*/

		var bundleComponents = componentSvc.list(
			lineId                         = product.getLine().getId(),
			modelId                        = product.getModel().getId(),
			includeBaseAttributeComponents = true
		);

		var bundleCost = calculateComponentsTotal( bundleComponents );

		addCost( "Costo componenti linea / modello", bundleCost );


		/*
			cost base product
		*/

		var productComponents = componentSvc.list( productId = productId, includeBaseAttributeComponents = true );

		var productCost = calculateComponentsTotal( productComponents );

		addCost( "Costo prodotto", productCost );


		/*
			cost items
		*/

		for ( var itemId in productItemIds ) {
			var itemComponents = componentSvc.list( productItemId = itemId, includeBaseAttributeComponents = true );

			var itemCost = 0;
			var compCost = 0;

			var productItem = getProductItemService().get( itemId );

			if ( !IsNull( priceAttr ) ) {
				compCost = calculateComponentsTotal( itemComponents );

				var amount = price.getAmount() ?: 0;
				itemCost   = compCost * amount;

				appendLog(
					message = "Trovato un costo generale -moltiplicativo- per questo attributo: #productItem.getId()#. Calcolo: #compCost# * #amount#;Costo: #formatExtended( itemCost )#"
				);
			} else {
				var price = productItem.getPrice( "PROD_ITEM_PRICE" );

				if ( !IsNull( price ) ) {
					var amount = price.getMethod()?.getAmount() ?: 0;

					if ( price.getMethod().getId() == "F" ) {
						appendLog(
							message = "Trovato un costo -fisso- per questo attributo: #price.getAmount()#. Non considero i costi dei componenti;Costo: #formatExtended( amount )#"
						);

						itemCost = amount;
					} else if ( price.getMethod().getId() == "M" ) {
						var compCost = calculateComponentsTotal( itemComponents );
						itemCost     = compCost * price.getAmount();

						appendLog(
							message = "Trovato un costo -moltiplicatore- per questo attributo: #price.getAmount()#. Applico: #compCost# * #price.getAmount()#;Costo: #formatExtended( itemCost )#"
						);
					}
				}
			}

			// itemCost = calculateComponentsTotal( itemComponents );

			addCost( "Costo item #itemId#", itemCost );
		}


		/*
			final price
		*/

		cost = calculateTotalCost();

		appendLog( message = " ;Totale costi: #formatExtended( cost )#" );

		price = ( cost * markup ) + fixedCost;

		appendLog(
			message = "Applico il markup:  ( costo:#cost# * markup:#markup# ) + costo fisso:#fixedCost#;Prezzo finale: #formatExtended( price )#"
		);

		var output = {
			"price"   = price,
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

		var name = ListLast(
			Replace(
				GetComponentMetadata( components[ 1 ] ).name,
				"Component",
				""
			),
			"."
		);

		appendLog( "* Inizio del calcolo del costo dei componenti #name#" );

		for ( var component in components ) {
			var name = "Componente: #component.getId()# articolo base: #component.getRawProduct().getId()# variante: #component.getVariant().getId()# colore: #component.getColor().getId()#";

			if ( !component.isDeleted() ) {
				var amount = component.getCost().getAmount();

				var quantity = component.getTotalQuantity(); // with override

				var rowTotal = amount * quantity;

				total = total + rowTotal;

				appendLog( "#name# - costo unitario: #amount# * quantità: #quantity#; Totale riga: #formatExtended( rowTotal )#" );
			} else {
				appendLog( "#name#;CANCELLATO" );
			}
		}

		appendLog( "* Fine del calcolo del costo dei componenti per #name#;Totale costo: #formatExtended( total )#" );

		return total;
	}

	private Void function addCost( required String label, required Numeric amount ){
		variables.costs.add( { "label" = label, "amount" = amount } );
	}

	private Void function appendLog( required String message, String productName ){
		if ( ListLen( message, ";" ) GT 2 ) {
			Throw(
				type    = "apirone.error.PriceCalculator.messageHasTooManyFields",
				message = "The log message can only have 2 fields (separated by ';')"
			)
		}

		if ( StructIsEmpty( variables.logConfig ) ) {
			if ( IsNull( productName ) ) {
				Throw(
					type    = "apirone.error.PriceCalculator.productNameRequired",
					message = "ProductName is required on the first invocation of appendLog()"
				)
			}

			startLog( productName );
		}

		var thisDate = DateTimeFormat( Now(), "yyyy-mm-dd HH:nn:ss" );

		var line = "#thisDate#;#variables.logConfig.productName#;#message##Chr( 10 )#";

		FileAppend( variables.logConfig.filePath, line );
	}

	private Struct function startLog( required String productName ){
		var util = new com.apirone.core.util.Udf();
		var name = util.prettyString( productName );

		var logsDir = ExpandPath( "/../repository/private/logs/prices" );

		if ( NOT DirectoryExists( logsDir ) ) {
			DirectoryCreate( logsDir, true );
		}

		var fileName = "product_"
		& DateTimeFormat( Now(), "yyyy-mm-dd_HH-nn-ss" )
		& "_" & name;

		if ( request.isDev() ) {
			fileName = "product_price_DEV_" & DateFormat( Now(), "yyyy-mm-dd" )
		}

		var fname = fileName & ".log";

		var filePath = logsDir & "/" & fname;

		FileWrite( filePath, "", "UTF-8" );

		variables.logConfig = { filePath = filePath, productName = productName }

		return logConfig;
	}

	private Numeric function calculateTotalCost(){
		var total = 0;

		for ( var item in variables.costs ) {
			total = total + item.amount
		}

		return total;
	}

	private Numeric function formatExtended( value ){
		return NumberFormat( value, ".9999" );
	}

}
