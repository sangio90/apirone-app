/*
	per signage:
		AND product_item_join_id = <cfqueryparam value="#arguments.signageItemProduct.productItemId#" cfsqltype="Integer">
		AND signage_config_item_join_id = <cfqueryparam value="#arguments.signageItemProduct.SignageConfigItemId#" cfsqltype="Integer">
*/

component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="productService" inject="ProductService";
	property name="productItemService" inject="ProductItemService";
	property name="quotationZoneService" inject="QuotationZoneService";
	property name="componentService" inject="ComponentService";
	property name="metadataService" inject="MetadataService";
	property name="currencyService" inject="CurrencyService";
	property name="quotationItemDAO" inject="QuotationItemDAO";

	variables.logConfig = {};
	variables.costs     = [];

	private function isPlaccaOrSegnaletica(product)
	{
		if (isNull(product) || isNull(product.getCategory()) || isNull(product.getCategory().getType())) {
			return false;
		}
		return ListFind( "PLA,SEG", product.getCategory().getType().getId() );
	}

	private function getQuantitaTotaleAltreRigheByQuotationLineIdAndFinishId(quotation, quotationItemId, lineId, finishId) {
		if ( IsNull( quotation ) ) {
			return 0;
		}
		arguments['quotationId'] = quotation.getId();
		return getQuotationItemDAO().getQuantitaTotaleAltreRigheByQuotationLineIdAndFinishId(argumentCollection = arguments);
	}

	public function calculate(
		required String productId,
		required Numeric quantity = 1,
		quotationItemZoneId = javacast("null", ""),
		Array producItemtIds,
		Numeric lettersQuantity = 0,
		Numeric simulationSignageConfigItemId,
		Quotation quotation = javacast("null", ""),
		QuotationItem quotationItem = javacast("null", "")
		){
		var price = simulate( argumentCollection = arguments );
		return { finalPrice: price.values.finalPrice, totalCost: price.values.totalCost };
	}

	public Struct function simulate(
		required String productId,
		required Numeric quantity = 1,
		quotationItemZoneId = javacast("null", ""),
		Array producItemtIds,
		String currencyId="EUR",
		Numeric lettersQuantity = 0,
		Numeric simulationSignageConfigItemId,
		Quotation quotation = javacast("null", ""),
		QuotationItem quotationItem = javacast("null", "")
	){
		if ( arguments.quantity LTE 0 ) {
			Throw(
				type    = "apirone.error.PriceCalculator.QuantityLessThenZero",
				message = "The quantity [#arguments.quantity#] must be greater than zero."
			);
		}

		variables.costs     = [];

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

		var markup = 0;

		var productSvc   = getProductService();
		var componentSvc = getComponentService();
		var metadataSvc  = getMetadataService();
		var currencySvc  = getCurrencyService();

		var productId      = arguments.productId;
		var productItemIds = arguments.producItemtIds;

		var product       = productSvc.get( productId );
		var price         = product.getPrice( "PRICE" );

		var quantity = arguments.quantity
		if (!isNull(arguments.quotationItemZoneId)) {
			var zone = getQuotationZoneService().get(arguments.quotationItemZoneId)
			var originZone = zone.getOrigin()
			var zoneQuantity = zone.getQuantity();
			if (!isNull(originZone)) {
				zoneQuantity *= originZone.getQuantity()
			}
			quantity = arguments.quantity * zoneQuantity;
		}


		//var currency = currencySvc.get( arguments.currencyId );

		var settings = metadataSvc.list( typeId=107 );
		var generalMarkup = settings[1].getValue();

		// TODO: verificare come gestire la mancanza di prezzo
		var isFixedPrice = ( price?.getMethod()?.getId() == "F" ?: true );
		var markup       = price?.getAmount() ?: 0;

		var name = "#product.getDescription()# (#product.getCode()#)";

		appendLog(
			message   = "Inizio calcolo del prezzo per #name#, quantità: #arguments.quantity#. Prezzo: fisso: #isFixedPrice#, valore: #markup#",
			productId = product.getSerial()
		);

		/*
			fixed cost
		*/

		var fixedCost     = product.getPrice( "COST_FIXED" )?.getAmount() ?: 0;
		var unitFixedCost = fixedCost / arguments.quantity;
		var quantitaTotale = arguments.quantity;
		if (isPlaccaOrSegnaletica(product)) {
			appendLog(
				message="Il prodotto è PLA o SEG, quindi i COST_FIXED li calcolo dividendo il costo fisso della tabella costi fissi linea_finitura su tutti gli altri articoli del preventivo"
			)
			if ( IsNull( arguments.quotationItem ) ) {
				appendLog(
					message="Siccome sto simulando il costo NON ho altri articoli con cui dividere il costo fisso, quindi divido solo per il campo quantità (#arguments.quantity#)"
				)
			}

			lineCostRecord = super.service( "LineCost" ).list(
				lineId   = product.getLine().getId(),
				finishId = product.getFinish().getId()
			);

			//Se non nullo leggo il campo "cost" e lo scrivo in fixedCost
			if ( len(lineCostRecord) > 0 ) {
				lineCostRecord = lineCostRecord[1];
				fixedCost += lineCostRecord.getCost();
				quantitaTotale = getQuantitaTotaleAltreRigheByQuotationLineIdAndFinishId(
					quotation,
					IsNull(quotationItem) ? null : quotationItem.getId(),
					product.getLine().getId(),
					product.getFinish().getId()
				);
				quantitaTotale += quantity;
				unitFixedCost = fixedCost / quantitaTotale;
			}

		}


		appendLog(
			message = "Costo fisso per #quantitaTotale# pezzi. Costo fisso #fixedCost# / #quantitaTotale#;Costo fisso unitario: #formatExtended( unitFixedCost )#"
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

		appendLog( "** Inizio del calcolo del prezzo degli attributi: #ArrayToList(productItemIds)#" );

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

			var priceProcessed = false;

			if ( !IsNull( productItemPrice ) ) {
				var amount = productItemPrice.getAmount() ?: 0;

				if ( productItemPrice.getMethod().getId() == "F" ) {
					appendLog(
						message = "#attributeName#. Prezzo -fisso- per questo attributo: #productItemPrice.getAmount()#. Salto i costi dei componenti;Costo attributo: #formatExtended( amount )#"
					);

					itemCost = amount;
					priceProcessed = true;
				} else if ( productItemPrice.getMethod().getId() == "M" ) {
					var compCost = calculateComponentsTotal( itemComponents );
					itemCost     = compCost * productItemPrice.getAmount();

					appendLog(
						message = "#attributeName#. Markup per questo attributo: #productItemPrice.getAmount()#. Totale componenti: #compCost# * markup: #productItemPrice.getAmount()#;Costo attributo: #formatExtended( itemCost )#"
					);

					priceProcessed = true;
				}
			} else {
				if ( !IsNull( attributePrice ) ) {
					compCost = calculateComponentsTotal( itemComponents );

					var amount = attributePrice.getAmount() ?: 0;

					itemCost = compCost * amount;

					appendLog(
						message = "Markup generale per questo attributo: #productItem.getId()#. Totale componenti: #compCost# * markup: #amount#;Costo attributo: #formatExtended( itemCost )#"
					);

					priceProcessed = true;
				}
			}

			if ( !priceProcessed ) {
				appendLog(
					message = "ATTENZIONE: Nessun prezzo (nè generale, nè specifico) trovato per l'attributo #attributeName# (id: #itemId#);Costo attributo: 0"
				);
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


		/*
			font price
		*/

		var letteringPrice = 0;
		if ( lettersQuantity > 0 && simulationSignageConfigItemId GT 0 ) {
			appendLog( "** Inizio del calcolo del prezzo della segnaletica con lettering con #lettersQuantity# lettere;" );
			var fontPricePerLetter = 0;
			var signageConfigItemSvc = super.service( "SignageConfigItem" );
			var signageConfigSvc = super.service( "SignageConfig" );
			var signageConfigItem    = signageConfigItemSvc.get( simulationSignageConfigItemId );
			var fontFamilySize = super.service( "FontFamilySize" ).get( signageConfigItem.getSize().getId() );

			if ( !IsNull( fontFamilySize ) && !isNull( signageConfigItem ) ) {
				var fontHeight = 0;
				var heightWidthRatio = 0;
				if ( isNull( fontFamilySize ) ) {
					appendLog( "ATTENZIONE: Impossibile recuperare l'altezza del font per il calcolo del prezzo della segnaletica." );
					return;
				}
				var fontHeight = fontFamilySize.getName();
				appendLog( "Altezza font: #fontHeight#mm" );

				var signageConfig = signageConfigSvc.get( signageConfigItem.getSignageConfigId() );
				var heightWidthRatio = signageConfig.getFont().getHeightWidthRatio();
				if  ( isNull( heightWidthRatio ) OR heightWidthRatio LTE 0 ) {
					appendLog( "ATTENZIONE: Impossibile recuperare il rapporto altezza/larghezza del font per il calcolo del prezzo della segnaletica." );
					return;
				}
				appendLog( "Larghezza font: #fontHeight / heightWidthRatio#mm" );

				var letteringThickeness = stringThicknessToDecimal( product.getModel().getCode() );
				if ( letteringThickeness GT 0 ) {
					appendLog( "Spessore font: #letteringThickeness#mm" );
				}

				var sizes = {
					"height" = fontHeight,
					"width"  = fontHeight / heightWidthRatio,
					"thickness" = letteringThickeness,
					"surfaceArea" = fontHeight * ( fontHeight / heightWidthRatio ),
					"volume" = letteringThickeness > 0 ? fontHeight * ( fontHeight / heightWidthRatio ) * letteringThickeness : 0
				}
				if ( sizes.surfaceArea GT 0 ) {
					appendLog( "Superficie font: #sizes.surfaceArea#mm²" );
				}
				if ( sizes.volume GT 0 ) {
					appendLog( "Volume font: #sizes.volume#mm³" );
				}
				if ( Len( productItemIds ) ) {
					//costo componenti items segnaletica
					for ( var productItemId in productItemIds ) {
						var fontPricePerLetter += calculateSignageProductItemPrice( signageItemProduct = { productItemId = productItemId, signageConfigItemId = simulationSignageConfigItemId }, attributePrice = attributePrice, sizes = sizes );
					}
				}

				//calcolo costo componenti segnaletica
				var signageBundleCost = 0;
				if ( IsInstanceOf( product, "com.apirone.core.model.bean.ProductComplex" ) ) {
					var signageBundleComponents = componentSvc.list(
						signageConfigItemId = simulationSignageConfigItemId,
						includeBaseAttributeComponents = true
					);

					var fontPricePerLetter += calculateComponentsTotal( signageBundleComponents );
				}

				addCost(
					"Costo componenti Segnaletica",
					fontPricePerLetter,
					"P"
				);

				letteringPrice = fontPricePerLetter * lettersQuantity;
			}

			appendLog( "** Fine del calcolo del prezzo della segnaletica con lettering; Costo per lettera: #formatExtended( fontPricePerLetter )#, Costo totale lettering: #formatExtended( fontPricePerLetter * lettersQuantity )#" );
		}


		letteringPriceString = letteringPrice GT 0 ? "+ costo lettering: #formatExtended( letteringPrice )#": "";

		var totalCost = bundleCost + productCost + totalCostItems + unitFixedCost + letteringPrice;
		appendLog(
			message    = "Costo finale fisso: bundle: #bundleCost# + prodotto: #productCost# + totale items: #totalCostItems# + costo fisso: #unitFixedCost# + #letteringPriceString# = Costo finale: #formatExtended( totalCost )#",
			lineTypeId = "H"
		);

		if ( isFixedPrice ) {
			var finalPrice = ( ( bundleCost + productCost + totalCostItems + unitFixedCost ) + markup + letteringPrice ) * generalMarkup;
			appendLog(
				message    = "Prezzo finale fisso. ( ( bundle: #bundleCost# + prodotto: #productCost# + totale items: #totalCostItems# + costo fisso: #unitFixedCost# ) + markup: #markup# #letteringPriceString# ) * markup generale: #generalMarkup#;Prezzo finale: #formatExtended( finalPrice )#",
				lineTypeId = "H"
			);
		} else {
			var finalPrice = ( ( ( bundleCost + productCost ) * markup ) + totalCostItems + unitFixedCost + letteringPrice ) * generalMarkup;
			appendLog(
				message    = "Prezzo finale. ( ( ( bundle: #bundleCost# + prodotto: #productCost# ) * markup: #markup# ) + totale items: #totalCostItems# + costo fisso: #unitFixedCost# #letteringPriceString# ) * markup generale: #generalMarkup#;Prezzo finale: #formatExtended( finalPrice )#",
				lineTypeId = "H"
			);
		}

		// disattivata la conversione, così non funziona, l'id di currency non è EUR, è un intero se usiamo verticale oppure un uuid se usiamo la nostra _currencies.
		// if( currency.getId() != "EUR" ){
		// 	var targetCurrency = currencySvc.get( arguments.currencyId );
		// 	var exchangeRate   = currencySvc.getExchangeRate( "EUR", currency.getId() );

		// 	finalPrice = finalPrice * exchangeRate;
		// 	finalCost  = finalCost * exchangeRate;
		// 	// all values

		// 	appendLog(
		// 		message    = "Conversione valuta da #currency.getCode()# a #targetCurrency.getCode()#. Tasso di cambio: #exchangeRate#;Prezzo finale convertito: #formatExtended( finalPrice )#;Costo finale convertito: #formatExtended( finalCost )#",
		// 		lineTypeId = "H"
		// 	);

		// }

		var output = {
			values = {
				"finalCost"      = finalCost,
				"bundleCost"     = bundleCost,
				"productCost"    = productCost,
				"totalCostItems" = totalCostItems,
				"totalCost"      = totalCost,
				"unitFixedCost"  = unitFixedCost,
				"finalPrice"     = finalPrice,
				"priceType"      = price
			},
			"currency" = "EUR",
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

				appendLog( "#name# - costo unitario: #amount#€ * quantità: #quantity#; Costo compon.: #formatExtended( rowTotal )#€" );
			} else {
				appendLog( "#name#;CANCELLATO" );
			}
		}

		appendLog( "* Fine del calcolo del costo dei componenti #compType#;Totale compon.: #formatExtended( total )#€" );

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

	private function calculateSignageProductItemPrice( Struct signageItemProduct, attributePrice, sizes ){
		componentSvc = getComponentService();
		var itemComponents = componentSvc.list( signageItemProduct = signageItemProduct );
		if ( Len( itemComponents ) EQ 0 ) {
			return;
		}
		var itemCost = 0;
		var compCost = 0;

		//recupero il product item id dalla struttura che uso per recuperare i componenti
		var itemId = signageItemProduct.productItemId;
		//recupero il product item
		var productItem = getProductItemService().get( itemId );

		var attributeName = "Signage Item: #itemId#, Attributo: #productItem.getAttribute().getName()# / #productItem
			.getAttributeValue()
			.getRawValue()
			.getName()#";

		// recupero il price specifico per l'item se presente
		var productItemPrice = productItem.getPrice( "PROD_ITEM_PRICE" );
		var priceProcessed = false;

		var markup = 0;
		if ( !IsNull( productItemPrice ) ) {
			// imposto il markup specifico per l'item
			markup = productItemPrice.getAmount();

			//se product item price è fisso non faccio nessun ragionamento o conversione sui componenti
			if ( productItemPrice.getMethod().getId() == "F" ) {
				appendLog(
					message = "#attributeName#. Prezzo -fisso- per questo attributo: #productItemPrice.getAmount()#. Salto i costi dei componenti;Costo attributo: #formatExtended( markup )#"
				);

				itemCost = markup;
				priceProcessed = true;
			}
		//se non è presente un price specifico per l'item o se esiste ma è percentuale e non fisso, uso il markup generale
		} else {
			if ( !IsNull( attributePrice ) ) {
				markup = attributePrice.getAmount();
			}
		}

		// per ora forzo il markup a 1 se è zero
		markup = markup > 0 ? markup : 1
		// qui entro solo se ho un markup e se non ho già processato il prezzo come fisso
		if ( priceProcessed == false ) {
			// calcolo il costo dei componenti
			for ( var itemComponent in itemComponents ) {
				var actualComponentCost = 0;
				var itemComponentCost = itemComponent.getCost().getAmount();
				if (itemComponentCost <= 0) {
					appendLog(
						message = "Componente: #itemComponent.getRawProduct().getName()#. Costo componente è zero, lo salto."
					);
					continue;
				}
				var itemComponentQuantity = itemComponent.getQuantity();
				if (itemComponentQuantity <= 0) {
					appendLog(
						message = "Componente: #itemComponent.getRawProduct().getName()#. Quantità componente è zero, lo salto."
					);
					continue;
				}
				//se componente è materia prima faccio i calcoli in base all'unità di misura
				if (itemComponent.getRawProduct().getProcessingType().getId() == 'MP') {
					// passaggi per ottenere il coefficiente dal metadata e l'unita di misura
					var rawValueId = productItem.getAttributeValue().getRawValue().getId();
					var metadata = metadataService.list( rawValueId = rawValueId );
					if ( Len( metadata ) == 0) {
						continue;
					}
					var valuedMetadataIndex = arrayFind(metadata, function(item) {
						return item.getValue() && item.getValue() > 0;
					});
					if (valuedMetadataIndex EQ 0) {
						continue;
					}
					var metadata = metadata[valuedMetadataIndex];
					var coefficient = metadata.getValue();
					var measurementUnit = metadata.getType().getMeasurementUnit().getId();
					appendLog( message = "Coefficiente su Unità di misura: #coefficient# #measurementUnit#" );
					/* dato che la quantita del comoponente può essere diversa da 1, divio il costo del componente per la quantità
					e.g. 13.25€ costo / 2 quantità = 6.625€ costo per unità di quantità in modo da poter fare le operazioni di conversione con in mano il // costo unitario. */
					var unitPrice = itemComponentCost / itemComponentQuantity;
					if (measurementUnit EQ 'KG-MMC') {
						//se ho perso per volume, prendo il volume della lettera e lo moltiplico per il coefficiente
						var weight = sizes.volume * coefficient
						appendLog( message = "Peso calcolato: #weight#kg da volume: #sizes.volume#mm³ e coefficiente: #coefficient# #measurementUnit#" );
						//prendo il prezzo unitario e lo moltiplico per il peso calcolato
						var weightPrice = unitPrice * weight;
						//sommo il costo al costo dei componenti
						compCost += weightPrice;
						actualComponentCost = weightPrice;
						appendLog( message = "Componente: #itemComponent.getRawProduct().getName()#. Costo calcolato per peso: #weightPrice#€ ricavato moltiplicando #unitPrice#€ per #weight#kg; Costo componente calcolato: #formatExtended( actualComponentCost )#€" );
					} else if (measurementUnit EQ 'MQ') {
						//uguale al volume, ma usero la superficie invece del volume per i calcoli
						var surfaceArea = sizes.surfaceArea * coefficient
						appendLog( message = "Superficie calcolata: #surfaceArea#mq da superficie: #sizes.surfaceArea#mm² e coefficiente: #coefficient# #measurementUnit#" );
						var surfaceAreaPrice = unitPrice * surfaceArea;
						compCost += surfaceAreaPrice;
						actualComponentCost = surfaceAreaPrice;
						appendLog( message = "Componente: #itemComponent.getRawProduct().getName()#. Costo calcolato per superficie: #surfaceAreaPrice#€ ricavato moltiplicando #unitPrice#€ per #surfaceArea#mq; Costo componente calcolato: #formatExtended( actualComponentCost )#€" );
					} else {
						actualComponentCost = itemComponentCost * itemComponentQuantity;
						compCost += actualComponentCost;
						appendLog(
							message = "Componente: #itemComponent.getRawProduct().getName()#. Costo unitario componente: #formatExtended( itemComponentCost )#€ * quantità: #itemComponentQuantity#; Costo componente calcolato: #formatExtended( actualComponentCost )#€"
						);
					}
				} else {
					//se non è materia prima sommo direttamente il costo moltiplicato per la quantità
					actualComponentCost = itemComponentCost * itemComponentQuantity;
					appendLog(
						message = "Componente: #itemComponent.getRawProduct().getName()#. Costo unitario componente: #formatExtended( itemComponentCost )#€ * quantità: #itemComponentQuantity#; Costo componente calcolato: #formatExtended( actualComponentCost )#€"
					);
					compCost += itemComponentCost * itemComponentQuantity;
				}

			}

			itemCost = compCost * markup;
			priceProcessed = true;
		}

		appendLog(
			message = "Markup generale per questo attributo: #productItem.getId()#. Totale componenti: #compCost# * markup: #markup#;Costo attributo: #formatExtended( itemCost )#"
		);

		if ( !priceProcessed ) {
			appendLog(
				message = "ATTENZIONE: Nessun prezzo (nè generale, nè specifico) trovato per l'attributo #attributeName# (id: #itemId#);Costo attributo: 0"
			);
		}

		addCost( "Costo attributo #itemId#", itemCost, "I" );
		return itemCost;
	}

	private function stringThicknessToDecimal(str) {
		str = trim(str);

		if (!find("-", str)) {
			return 0;
		}

		var parts = listToArray(str, "-");
		var integerPart = val(parts[1]);
		var decimalPart = 0;

		if (arrayLen(parts) > 1 && len(parts[2])) {
			decimalPart = val(parts[2]);
			if (len(parts[2]) == 1) {
				decimalPart = decimalPart * 10;
			}
		}

		return integerPart + (decimalPart / 100);
	}
}
