component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	variables.verticaleUser = "apikey";
	variables.verticalePwd = "Gs16072001!";
	variables.verticaleSecret = ToBase64('#variables.verticaleUser#:#variables.verticalePwd#');

	property name="dao" inject="QuotationDAO";

	//Ho ordinato i DAO in ordine di cancellazione, se elimino in questo ordine non dovrei avere problemi con la cancellazione a cascata
	property name="QuotationStatusHistoryService" inject="QuotationStatusHistoryService";
	property name="QuotationItemPriceLineService" inject="QuotationItemPriceLineService";
	property name="QuotationPriceService" inject="QuotationPriceService";
	property name="QuotationItemSignageRowService" inject="QuotationItemSignageRowService";
	property name="QuotationItemProductItemService" inject="QuotationItemProductItemService";
	property name="QuotationPriceLineService" inject="QuotationPriceLineService";
	property name="QuotationItemPriceService" inject="QuotationItemPriceService";
	property name="QuotationItemFruitPositionService" inject="QuotationItemFruitPositionService";
	property name="QuotationItemFruitService" inject="QuotationItemFruitService";
	property name="QuotationZonePositionService" inject="QuotationZonePositionService";
	property name="QuotationZoneService" inject="QuotationZoneService";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="QuotationService" inject="QuotationService";


	// TODO capire se questo service esiste ancora dal momento che la tabella sul DB non c'e', viene usato nella clone
	property name="QuotationItemPositionService" inject="QuotationItemPositionService";

	property name="exportCodeService" inject="ExportCodeService";
	property name="rawValueService" inject="RawValueService";
	property name="attributeService" inject="AttributeService";
	property name="userService" inject="UserService";
	property name="profileService" inject="ProfileService";
	property name="langService" inject="LangService";
	property name="statusService" inject="StatusService";
	property name="signageConfigService" inject="signageConfigService";
	property name="SignageConfigItemService" inject="SignageConfigItemService";
	property name="pricelistService" inject="PricelistService";
	property name="paymentMethodService" inject="PaymentMethodService";
	property name="currencyService" inject="CurrencyService";
	property name="customerService" inject="CustomerService";
	property name="opportunityService" inject="OpportunityService";
	property name="leadService" inject="LeadService";
	property name="productService" inject="ProductService";
	property name="productCategoryService" inject="ProductCategoryService";
	property name="lineService" inject="LineService";
	property name="modelService" inject="ModelService";
	property name="finishService" inject="FinishService";
	property name="productItemService" inject="ProductItemService";
	property name="componentService" inject="ComponentService";
	property name="vatCodeService" inject="VatCodeService";
	property name="countryService" inject="CountryService";
	property name="fileService" inject="FileService";
	property name="ProductHashService" inject="ProductHashService";

	property name="cacheScope" type="String" default="Quotation.bean";

	public com.apirone.core.model.bean.Quotation function get( required String quotationId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.quotationId );
		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationId );
		cm.put( getCacheScope(), arguments.quotationId, bean );

		return bean;
	}

	public Number function getNextNumber(){

		return getDao().readNextNumber();

	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotation.createdAt", dir = "desc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( quotationId = record.quotation_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String quotationId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.quotationId );

		outcome.setData( { quotationId = arguments.quotationId } );

			try {
				transaction {
					quotationPrices = getQuotationPriceService().list( quotationId = arguments.quotationId );
					for ( var price in quotationPrices ) {
						getQuotationPriceLineService().deleteByQuotationPriceId( price.getId() );
						getQuotationPriceService().delete( price.getId() );
					}

					//Elimino quotationstatushistory
					quotationStatusHistory = getQuotationStatusHistoryService().list( quotationId = arguments.quotationId );
					for ( var history in quotationStatusHistory ) {
						getQuotationStatusHistoryService().delete( history.getId() );
					}

					quotationItems = getQuotationItemService().list( quotationId = arguments.quotationId );
					for ( var item in quotationItems ) {
						//Elimino i quotation item price
						quotationItemPrices = getQuotationItemPriceService().list( quotationItemId = item.getId() );
						for ( var itemPrice in quotationItemPrices ) {
							getQuotationItemPriceService().delete( itemPrice.getId() );
						}

						//Elimino i quotation item fruit
						quotationItemFruits = getQuotationItemFruitService().list( quotationItemId = item.getId() );
						for ( var fruit in quotationItemFruits ) {
							//Elimino i quotation item fruit position
							quotationItemFruitPositions = getQuotationItemFruitPositionService().list( quotationItemFruit = fruit.getId() );
							for ( var fruitPosition in quotationItemFruitPositions ) {
								getQuotationItemFruitPositionService().delete( fruitPosition.getId() );
							}
							getQuotationItemFruitService().delete( fruit.getId() );
						}

						quotationItemSignageRows = getQuotationItemSignageRowService().list( quotationItemId = item.getId() );
						for ( var signageRow in quotationItemSignageRows ) {
							getQuotationItemSignageRowService().delete( signageRow.getId() );
						}

						quotationItemsProductItems = getQuotationItemProductItemService().list( quotationItemId = item.getId() );
						for ( var quotationItemProductItem in quotationItemsProductItems ) {
							getQuotationItemProductItemService().delete( quotationItemProductItem.getId() );
						}
						getQuotationItemService().delete( item.getId() );

					}

					var quotationZones = getQuotationZoneService().list( quotationId = arguments.quotationId );

					for ( var zone in quotationZones ) {
						deleteQuotationZonesRecursive( zone.getId() );
					}

					getDao().delete( arguments.quotationId );
				}
			} catch ( any error ) {
				transaction action="rollback";
				rethrow
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotation" );
				outcome.setMessage( "Cannot delete quotation [#arguments.quotationId#]" );
				return outcome;
			}


		// var cm = getCacheManager();
		// cm.remove( getCacheScope(), arguments.quotationId );


		return outcome;
	}

	private void function deleteQuotationZonesRecursive(zoneId) {
		var quotationZones = getQuotationZoneService().list(originId = arguments.zoneId);
		for (var zone in quotationZones) {
			var quotationZonePositions = getQuotationZonePositionService().list(zoneId = zone.getId());
			for (var zonePosition in quotationZonePositions) {
					getQuotationZonePositionService().delete(zonePosition.getId());
			}
			deleteQuotationZonesRecursive(zone.getId());
			getQuotationZoneService().delete(zone.getId());
		}
	}

	// questa firma no è pulita ma è il miglior adattamento
	// questo metodo andrà usato anche da sistemi esterni e legarsi alla session non è consentito
	public String function create(
		required com.apirone.core.model.bean.Quotation quotation,
		required String userId,
		Boolean isClone = false,
		Boolean isPromoteStatus = false,
	){
		if (!isPromoteStatus) {
			arguments.quotation.setQuotationNumber( getNextNumber() );
			arguments.quotation.setVersionNumber( 1 );
		}

		transaction {

			var newId = getDao().insert( arguments.quotation );

			/*
				add first status to history
			*/
			var history = super.bean( "QuotationStatusHistory" );
			var status = getStatusService().get( "LAV" );

			history.setQuotationId( newId );
			history.setStatus( status );
			history.setUser( getUserService().get( arguments.userId ) );

			getQuotationStatusHistoryService().create( history );


			if (!isClone && !isPromoteStatus) {
				/*
					add first zone
				*/
				var zone = super.bean( "QuotationZone" );
				var newQuotation = super.bean( "Quotation" );
				newQuotation.setId( newId );

				zone.setQuotation( newQuotation );
				zone.setName( "Non assegnato" );
				zone.setQuantity(1);

				getQuotationZoneService().create( zone );
			}

		}

		return newId;

	}


	public String function update( required com.apirone.core.model.bean.Quotation quotation ){
		getDao().update( arguments.quotation );
		super.getCacheManager().remove( getCacheScope(), arguments.quotation.getId() );

		return arguments.quotation.getId();
	}

	public Struct function exportProducts( required com.apirone.core.model.bean.QuotationItem[] quotationItems ){

		var result = {
			"success" = true,
			"error" = null
		};

		transaction {
			if ( arguments.quotationItems.len() ) {
				// ciclo su tutti i prodotti del preventivo
				for ( var quotationItem in arguments.quotationItems ) {
					var isSpeciale = quotationItem.getSpecial() ? "S" : "N";
					//se tipo servizio, la gestione è light
					if (!isNull(quotationItem.getArticle())) {
						var dataExport = {
							"AR_CHIAVE" = quotationItem.getArticle().getCode() & RepeatString( "0", 31 - Len( quotationItem.getArticle().getCode() ) ),
							"ARCODART"  = quotationItem.getArticle().getCode() & RepeatString( "0", 15 - Len( quotationItem.getArticle().getCode() ) ),
							"ARDESART"  = quotationItem.getArticle().getDescription().subString( 0, Len(quotationItem.getArticle().getDescription()) ) & RepeatString(
								"0",
								35 - Len( quotationItem.getArticle().getDescription().subString( 0, Len(quotationItem.getArticle().getDescription()) ) )
							),
							"ARDESSUP"  = "",
							"ARDATCAR"  = Now(),
							"ARUNMIS1"  = "PZ",
							"VARCOD"    = "0000000000",
							"VARNOT"    = "",
							"CLCODICE"  = "000000",
							"CLANNOTA"  = quotationItem.getNote(),
							"ARIMG_64" = "",
							"ARSPECIA" = isSpeciale,
							"ARCODNOM" = ""
						}

						// non abbiamo un prodotto legato a questa riga, quindi cerchiamo per codice e basta tra i codici gia esportati.
						var existingCodes = exportCodeService.list(
							str = quotationItem.getArticle().getCode() & RepeatString( "0", 25 - Len( quotationItem.getArticle().getCode() ) )
						);

						if ( existingCodes.len() > 0 ) {
							continue;
						}

						///se non troviamo, creiamo ed esportiamo in verticale
						var exportCode = super.bean( "ExportCode" );
						exportCode.setName( quotationItem.getArticle().getCode() & RepeatString( "0", 25 - Len( quotationItem.getArticle().getCode() ) ) );
						exportCode.setCounter( "000000" );
						exportCodeService.create( "exportCode" = exportCode );
						result.success = getDao().exportProduct( dataExport );

						continue;
					} else {
						var hsCode = "";
						try {
							hsCode = quotationItem.getProduct().getLine().getHscode();
						} catch ( any e ) {
							
						}
						var quotationImageFile = quotationItem.getImage();
						var base64File = "";						

						try {
							var path = expandPath("/../repository/public/media/quotation-items/500/" & quotationImageFile.getDirectory() & "/" & quotationImageFile.getName());
							var file = FileReadBinary(path);	
							if (!isNull(file)) {
								base64File = ToBase64(file);
							}
						} catch ( any e ) {
							
						}
						
						//in caso il prodotto non sia un servizio, ma un prodotto con hash, la gestione è più complessa
						if ( isNull(quotationItem.getHash()) || Trim( quotationItem.getHash() ) == "" ) {
							result.success = false;
							result.error = 'Hash riga preventivo non trovata.';
						}
						var productHash = getProductHashService().getByHash( quotationItem.getHash() );
						if ( isNull(productHash) ) {
							result.success = false;
							result.error = 'Hash prodotto non trovato.';
						}
						//appurato che la riga di preventivo ha un hash associato e che l'hash corrisponda effettivamente ad un record sulla tabella degli hash
						//cerchiamo se l'hash è gia stato associato ad un codice esportato in verticale.
						var existingCode = exportCodeService.list( "productHashId" = productHash.getId() );
						if ( existingCode.len() > 0 ) {
							continue;
						}

						//se non lo troviamo, trasformiamo i dati da jason a struttura e poterla consultare e poter creare un nuovo codice
						//e i nuovi record nella tabella degli articoli e delle rispettive diba su verticale.
						var quotationItemData = deserializeJson( productHash.getJsonData() );
						var code = "";

						//prime due cose: cerchiamo il prodotto corrispondente all'id preso dall'hash e prendiamo categoria,
						//linea, modello e finitura per comporre la prima parte del codice.
						var product = getProductService().get( quotationItemData.productId );
						var category = getProductCategoryService().get( quotationItemData.categoryId );
						if ( IsNull( product ) || IsNull( category ) ) {
							result.success = false;
							result.error = 'Prodotto o Categoria Prodotto non trovata.'
							return result;
						}

						var categoryCode = Trim( category.getCode() );
						code &= categoryCode;
						var note = "";

						var line = getLineService().get( quotationItemData.lineId );
						if ( IsNull( line ) ) {
							result.success = false;
							result.error = "Linea prodotto non trovata."
							return result;
						}
						var lineCode = Trim( line.getCode() );
						code &= lineCode;

						var model = getModelService().get( quotationItemData.modelId );
						if ( IsNull( model ) ) {
							result.success = false;
							result.error = "Modello prodotto non trovato."
							return result;
						}
						code &= Trim( model.getCode() );

						var finish = getFinishService().get( quotationItemData.finishId );
						if ( IsNull( finish ) ) {
							result.success = false;
							result.error = "Finitura prodotto non trovata."
							return result;
						}
						var finishCode = Trim( finish.getCode() );
						code &= finishCode;

						var description = product.getDescription().left( 35 );

						//inizializiamo il codice variane, il codice colore e le note segnaletica.
						var arKey = code;
						var colCode  = "000000";
						var varCode  = "";
						var noteSegnaletica = '';

						//se l'articolo è una segnaletica
						if (StructKeyExists( quotationItemData, "signageRows" ) ) {
							var signageConfigItem = getSignageConfigItemService().get( quotationItemData.signageConfigItemId );
							var fontSize = signageConfigItem.getSize().getName();
							var signageConfig = getSignageConfigService().get( signageConfigItem.getSignageConfigId() );
							var fontCode = signageConfig.getFont().getCode();
							var fontName = signageConfig.getFont().getName();
							note &= "Font: " & fontName & "; Font Size: " & fontSize & "; "
							//il varcode viene popolato con
							varCode = right("00000" & fontCode, 5) & right("00000" & fontSize, 5);
							var signageRowsCounter = 1;
							for ( var signageRow in quotationItemData.signageRows ) {
								noteSegnaletica &= 'riga ' & signageRowsCounter & ': Allineamento: ' & signageRow['text-align'] & ': Testo: "' & signageRow.content & '"";';
								signageRowsCounter++;
							}
						}

						var productItemIds = [];
						var productItems   = [];
						var importantAttributes = product.getImportantAttributes();
						for ( var quotationItemProductItem in quotationItemData.productItems ) {
							var productItem = getProductItemService().get( quotationItemProductItem.productItemId );
							if ( !IsNull( productItem ) ) {
								var attributeValue = productItem.getAttributeValue();
								var attribute      = attributeService.get( attributeId = attributeValue.getAttributeId() );

								if ( IsNull( attribute ) ) {
									result.success = false;
									result.error = 'Attributo Prodotto non trovato.';
									return result;
								}
								var rawValue = attributeValue.getRawValue();
								// cerco negli important attributes del prodotto l'attributo su cui sto ciclando.
								// se lo trovo lo imposto come importante, a patto che non ne siano gia stati trovati 2 (len 10)

								var isImportant = false;
								if (!isNull(importantAttributes)) {
									isImportant = importantAttributes.some(function(item) {
										return item.getId() == attribute.getId();
									});
								}

								if (isImportant) {
									if ( varCode.len() < 10 ) {
										varCode &= Trim( attribute.getCode() ) & Trim( rawValue.getCode() );
										arrayAppend(productItems, {
											"important"   = true,
											"rawValueId"  = rawValue.getId(),
											"attributeId" = attributeValue.getAttributeId()
										} );
									} else {
										arrayAppend(productItems, {
											"important"   = false,
											"rawValueId"  = rawValue.getId(),
											"attributeId" = attributeValue.getAttributeId()
										} );
									}
								} else {
									arrayAppend(productItems, {
										"important"   = false,
										"rawValueId"  = rawValue.getId(),
										"attributeId" = attributeValue.getAttributeId()
									} );
								}
								arrayAppend(productItemIds, productItem.getId())
							}

							note &= attribute.getName() & ": " & rawValue.getName() & "; ";
						}

						var productComponents = getComponents( product.getId(), quotationItem, productItemIds );
						varCode &= RepeatString( "0", 10 - Len( varCode ) )

						//se placca
						if (StructKeyExists( quotationItemData, "fruits" ) ) {
							var orientation = quotationItem.getFrame().getOrientation().getName()
							note &= "Orientamento: " & orientation & ";";

							var fruits = quotationItemData.fruits;
							if (Len(fruits)) {
								note &= " Frutti: "
							}
							fruitsIndex = 1;
							var fruitsComponents = []
							for ( var fruit in fruits ) {
								var fruitBean = getProductService().get( fruit.product );
								note &= " " & fruitBean.getCode()
								var fruitItems = fruit.productItems;
								if (Len(fruitItems)) {
									note &= ": "
									fruitsProductItems[fruitsIndex] = [];
									fruitsProductItemIds[fruitsIndex] = [];
									for ( var fruitItem in fruitItems ) {
										var fruitItemBean = getProductItemService().get( fruitItem.productItemId );
										var attributeValue = fruitItemBean.getAttributeValue();
										var attribute      = attributeService.get( attributeId = attributeValue.getAttributeId() );

										if ( IsNull( attribute ) ) {
											result.success = false;
											result.error = 'Attributo Frutto non trovato.';
											return result;
										}
										var rawValue = attributeValue.getRawValue();
										arrayAppend( fruitsProductItems[fruitsIndex], {
											"important"   = false,
											"rawValueId"  = rawValue.getId(),
											"attributeId" = attributeValue.getAttributeId()
										} );
										arrayAppend( fruitsProductItemIds[fruitsIndex], productItem.getId() );
										note &= attribute.getName() & ": " & rawValue.getName() & "; ";
										if (fruitItem.note != "") {
											note &= " Note: " & fruitItem.note & "; ";
										}
									}

								}
								//per ogni frutto recupero i componenti
								arrayAppend(fruitsComponents, getComponents( fruit.product, quotationItem, fruitsProductItemIds[fruitsIndex] ));
								fruitsIndex++;
							}
						}

						var exportCode = super.bean( "ExportCode" );
						exportCode.setName( code & varCode );
						exportCode.setProductHashId( productHash.getId() );
						var maxCounter = exportCodeService.max( exportCode = code & varCode );
						if (maxCounter > 0) {
							var newMaxCounter = NumberFormat( maxCounter + 1, "000000" )
							exportCode.setCounter( newMaxCounter );
							colCode = newMaxCounter
						} else {
							exportCode.setCounter( "000001" );
							colCode = "000001"
						}
						var exportCodeId = exportCodeService.create( "exportCode" = exportCode );
					}


					arKey = code & varCode & colCode;
					var dataExport = {
						"AR_CHIAVE" = arKey,
						"ARCODART"  = code & RepeatString( "0", 15 - Len( code ) ),
						"ARDESART"  = description,
						"ARDESSUP"  = quotationItemData.special == 'true' ? 'SÌ DWG' : 'NO DWG',
						"ARDATCAR"  = Now(),
						"ARUNMIS1"  = "PZ",
						"VARCOD"    = varCode,
						"VARNOT" = noteSegnaletica,
						"CLCODICE"  = colCode,
						"CLANNOTA"  = note,
						"ARIMG_64"  = base64File,
						"ARSPECIA" = isSpeciale,
						"ARCODNOM" = hsCode
					}

					result.success = getDao().exportProduct( dataExport );

					var allComponents = [];
					for ( var productComponent in productComponents ) {
						productComponent.DS_CHIAVE = dataExport.AR_CHIAVE;
						productComponent.DSCODART  = dataExport.ARCODART;
						productComponent.DSCODVAR  = dataExport.VARCOD;
						productComponent.DSCODCOL  = dataExport.CLCODICE;

						ArrayAppend(allComponents, productComponent);
					}

					if (StructKeyExists( quotationItemData, "fruits" ) ) {
						for ( var fruitComponents in fruitsComponents ) {
							for ( var fruitComponent in fruitComponents ) {
								fruitComponent.DS_CHIAVE = dataExport.AR_CHIAVE;
								fruitComponent.DSCODART  = dataExport.ARCODART;
								fruitComponent.DSCODVAR  = dataExport.VARCOD;
								fruitComponent.DSCODCOL  = dataExport.CLCODICE;

								ArrayAppend(allComponents, fruitComponent);
							}
						}
					}

					var grouped = {};

					for (var row in allComponents) {
						var key = row.DSCODMAT & "|" & row.DSVARMAT & "|" & row.DSCOLMAT;
						if ( !structKeyExists(grouped, key) ) {
							grouped[key] = duplicate(row);
							grouped[key].DSQTAMOV = val(row.DSQTAMOV);
						} else {
							grouped[key].DSQTAMOV += val(row.DSQTAMOV);
						}
					}
					var parsedComponents = [];

					for (var key in grouped) {
						arrayAppend(parsedComponents, grouped[key]);
					}

					var counter = 0;
					for (var row in parsedComponents) {
						counter++;
						row.CPROWNUM = counter;
						row.CPROWORD = counter * 10;
						row.DSDATCRE = DateFormat(now(), "yyyy-mm-dd");
						result.success = getDao().exportDiba( row );
					}
				}
			}
		}

		return result;
	}

	public Struct function export( required com.apirone.core.model.bean.QuotationItem[] quotationItems ){
		var result = {
			'success' = false,
			'error' = null
		};

		transaction {
			if (quotationItems.len() > 0) {
				var quotation = quotationItems[1].getQuotation();

				getDao().deleteExport( quotationNumber = quotation.getQuotationNumber() );
				quotationDataResult = prepareExportData(quotation);
				if (!isNull(quotationDataResult.error)) {
					result.error = quotationDataResult.error;
					return result;
				}
				quotationDataHead = quotationDataResult.data;
			}

			quotationItemsToExport = [];
			if ( quotationItems.len() > 0 ) {
				var index = 1;
				for ( var quotationItem in arguments.quotationItems ) {
					var salesAgent = quotation.getSalesAgent();
					var graphicTechnician = quotation.getGraphicTechnician();
					var salesAgentId = 0;
					var graphicTechnicianId = 0;
					if (!isNull(salesAgent)) {
						salesAgentId = salesAgent.getAccount().getIdUtenteVerticale();
					}
					if (!isNull(graphicTechnician)) {
						graphicTechnicianId = graphicTechnician.getAccount().getIdUtenteVerticale();
					}

					var quotationData = {}
					quotationData.append(quotationDataHead);

					if (!isNull(quotationItem.getArticle())) {
						var product = null
						var code = quotationItem.getArticle().getCode() & RepeatString( "0", 15 - Len( quotationItem.getArticle().getCode() ) ) & "0000000000"
						var existingCodes = exportCodeService.list( str = code );
						if ( existingCodes.len() == 0 ) {
							result.error = 'Prima esporta gli articoli.';
							return result;
						}

						var data = {
							"AR_CHIAVE" = quotationItem.getArticle().getCode() & RepeatString( "0", 31 - Len( quotationItem.getArticle().getCode() ) ),
							"ARCODART"  = quotationItem.getArticle().getCode() & RepeatString( "0", 15 - Len( quotationItem.getArticle().getCode() ) ),
							"ARDESART"  = quotationItem.getArticle().getDescription().subString( 0, Len(quotationItem.getArticle().getDescription()) ) & RepeatString(
								"0",
								35 - Len( quotationItem.getArticle().getDescription().subString( 0, Len(quotationItem.getArticle().getDescription()) ) )
							),
							"ARDESSUP"  = "",
							"ARDATCAR"  = Now(),
							"ARUNMIS1"  = "PZ",
							"VARCOD"    = "0000000000",
							"CLCODICE"  = "000000",
							"CLANNOTA"  = quotationItem.getNote()
						}

						var quotationItemQuantity = quotationItem.getQuantity()
						if (!isNull(quotationItem.getQuotationZone())) {
							if (!isNull(quotationItem.getQuotationZone().getOrigin())) {
								quotationItemQuantity *= quotationItem.getQuotationZone().getOrigin().getQuantity()
							}
							quotationItemQuantity *= quotationItem.getQuotationZone().getQuantity()
						}
						quotationData["CPROWNUM"] = index;
						quotationData["CPROWORD"] = index * 10;
						quotationData["MMCODART"] = data["ARCODART"];
						quotationData["MMCODVAR"] = data["VARCOD"];
						quotationData["MMCODCOL"] = data["CLCODICE"];
						quotationData["ARUNMIS1"] = "PZ";
						quotationData["MMQTAMOV"] = quotationItemQuantity;
						quotationData["MMVALUNI"] = !isNull(quotationItem.getPrice()) ? quotationItem.getPrice().getAmount() : 0;
						quotationData["MMSCOAR1"] = !isNull(quotationItem.getPrice()) ? quotationItem.getPrice().getDiscount1() : 0;
						quotationData["MMSCOAR2"] = !isNull(quotationItem.getPrice()) ? quotationItem.getPrice().getDiscount2() : 0;
						quotationData["MMEVASIO"] = quotation.getValidityDate();
						quotationData["MM_STATO"] = "N";
						quotationData["MMUTECOM"] = salesAgentId;
						quotationData["MMUTETEC"] = graphicTechnicianId;
					} else {
						//in caso il prodotto non sia un servizio, ma un prodotto con hash, la gestione è più complessa
						if ( isNull(quotationItem.getHash()) || Trim( quotationItem.getHash() ) == "" ) {
							result.success = false;
							result.error = 'Hash riga preventivo non trovata.';
						}
						var productHash = getProductHashService().getByHash( quotationItem.getHash() );
						if ( isNull(productHash) ) {
							result.success = false;
							result.error = 'Hash prodotto non trovato.';
						}
						//appurato che la riga di preventivo ha un hash associato e che l'hash corrisponda effettivamente ad un record sulla tabella degli hash
						//cerchiamo se l'hash è gia stato associato ad un codice esportato in verticale.
						var existingCode = exportCodeService.list( "productHashId" = productHash.getId() );
						if ( existingCode.len() > 0 ) {
							var code = existingCode[1].getName().left( 15 );
							var varCode = existingCode[1].getName().right( 10 );
							var colCode = existingCode[1].getCounter();

						} else {
							//se non esiste nemmeno il varCode negli exported vuol dire che non è sicuramente mai stato fatta la export articoli
							result.error = 'Prima esporta gli articoli. ' & code & varCode;
							return result;
						}

						var quotationItemQuantity = quotationItem.getQuantity()
						if (!isNull(quotationItem.getQuotationZone())) {
							if (!isNull(quotationItem.getQuotationZone().getOrigin())) {
								quotationItemQuantity *= quotationItem.getQuotationZone().getOrigin().getQuantity()
							}
							quotationItemQuantity *= quotationItem.getQuotationZone().getQuantity()
						}
						quotationData['CPROWNUM'] = index;
						quotationData['CPROWORD'] = index * 10;
						quotationData['MMCODART'] = code & RepeatString( "0", 15 - Len( code ) );
						quotationData['MMCODVAR'] = varCode;
						quotationData['MMCODCOL'] = colCode;
						quotationData['ARUNMIS1'] = "PZ";
						quotationData['MMQTAMOV'] = quotationItemQuantity;
						var price = 0
						var discount1 = 0
						var discount2 = 0
						if (!isNull(quotationItem.getPrice())) {
							if (quotationItem.getPrice().getAmount() > 0) {
								price = quotationItem.getPrice().getAmount()
							} else {
								price = quotationItem.getPrice().getTotal()
							}
							if (quotationItem.getPrice().getDiscount1() > 0) {
								discount1 = !isNull(quotationItem.getPrice().getDiscount1()) ? quotationItem.getPrice().getDiscount1() : 0
							}
							if (quotationItem.getPrice().getDiscount2() > 0) {
								discount2 = !isNull(quotationItem.getPrice().getDiscount2()) ? quotationItem.getPrice().getDiscount2() : 0
							}
						}
						quotationData["MMVALUNI"] = (discount1 > 0 || discount2 > 0) ? getOriginalPrice( finalPrice = price, discount1 = discount1, discount2 = discount2 ) : price;
						quotationData['MMSCOAR1'] = discount1;
						quotationData['MMSCOAR2'] = discount2;
						quotationData['MMEVASIO'] = quotation.getValidityDate();
						quotationData['MM_STATO'] = 'N';
						quotationData["MMUTECOM"] = salesAgentId;
						quotationData["MMUTETEC"] = graphicTechnicianId;
					}
					ArrayAppend( quotationItemsToExport, quotationData );
					index = index + 1;
				}

				for ( quotationItemToExport in quotationItemsToExport ) {
					getDao().export( quotationItemToExport );
				}

				var quotationPrice = getQuotationPriceService().calculate( quotation.getId() );
				if (!isNull(quotationPrice) && quotationPrice.getFlatDiscount() > 0) {
					var quotationPriceData = {}
					quotationPriceData.append(quotationDataHead);
					quotationPriceData['MMCODART'] = "000000000SCONTO";
					quotationPriceData['MMCODVAR'] = "0000000000";
					quotationPriceData['MMCODCOL'] = "00000";
					quotationPriceData['MMVALUNI'] = quotationPrice.getFlatDiscount();
					quotationPriceData['MMQTAMOV'] = 1;
					quotationPriceData["MMEVASIO"] = quotation.getValidityDate();
					quotationPriceData["MM_STATO"] = "N";
					quotationPriceData['CPROWNUM'] = index;
					quotationPriceData['CPROWORD'] = index * 10;
					quotationPriceData["MMUTECOM"] = salesAgentId;
					quotationPriceData["MMUTETEC"] = graphicTechnicianId;
					getDao().export( quotationPriceData );
				}
			}
		}

		result.success = true;

		// notifyOrdersVerticale();

		return result;
	}

	function getOriginalPrice(required numeric finalPrice, required numeric discount1, required numeric discount2) {
		var s1 = discount1 / 100;
		var s2 = discount2 / 100;

		var divisor = (1 - s1) * (1 - s2);

		if (divisor == 0) {
			throw(message = "Divisione per zero: controlla gli sconti");
		}

		return finalPrice / divisor;
	}

	public function getComponents(
		required String productId,
		required quotationItem,
		Array productItemIds
	){
		var quantity      = quotationItem.getQuantity() ? quotationItem.getQuantity() : 1;
		var allComponents = [];

		var productSvc   = getProductService();
		var componentSvc = getComponentService();

		var productId      = arguments.productId;
		var productItemIds = arguments.productItemIds;

		var product = productSvc.get( productId );
		if ( IsInstanceOf( product, "com.apirone.core.model.bean.ProductComplex" ) ) {

			var bundleComponents = componentSvc.list(
				lineId                         = product.getLine().getId(),
				modelId                        = product.getModel().getId(),
				includeBaseAttributeComponents = true
			);

			for ( var bundleComponent in bundleComponents ) {
				ArrayAppend(allComponents, parseComponent( bundleComponent ));
			}

			if ( IsInstanceOf( quotationItem, "com.apirone.core.model.bean.QuotationItemSignage" ) ) {
				var signageComponents = componentSvc.list(
					signageConfigItemId            = quotationItem.getSignageConfigItem().getId(),
					includeBaseAttributeComponents = true
				);

				if ( productItemIds.len() > 0 ) {
					for ( var productItemId in productItemIds ) {
						var signageProductComponents = componentSvc.list(
							signageItemProduct = {
								signageConfigItemId = quotationItem.getSignageConfigItem().getId(),
								productItemId       = productItemId
							},

							includeBaseAttributeComponents = true
						);

						for ( var signageProductComponent in signageProductComponents ) {
							ArrayAppend(allComponents, parseComponent( signageProductComponent ));
						}
					}
				}

				for ( var signageComponent in signageComponents ) {
					ArrayAppend(allComponents, parseComponent( signageComponent ));
				}
			}
		}

		var productComponents = componentSvc.list( productId = product.getId(), includeBaseAttributeComponents = true );

		for ( var productComponent in productComponents ) {
			ArrayAppend(allComponents, parseComponent( productComponent ));
		}

		if ( productItemIds.len() > 0 ) {
			for ( var productItemId in productItemIds ) {
				var productItemComponents = componentSvc.list(
					productItemId                  = productItemId,
					includeBaseAttributeComponents = true
				);
				for ( var productItemComponent in productItemComponents ) {
					ArrayAppend(allComponents, parseComponent( productItemComponent ));
				}
			}
		}

		return allComponents;
	}

	public function parseComponent( com.apirone.core.model.bean.Component component ){
		var componente  = {
			"DS_CHIAVE" = "",
			"DSCODART"  = "",
			"DSCODVAR"  = "",
			"DSCODCOL"  = "",
			"DSCODMAT"  = component.getRawProduct()?.getId(),
			"DSVARMAT"  = component.getVariant().getId(),
			"DSCOLMAT"  = component.getColor().getId(),
			"DSQTAMOV"  = component.getQuantity(),
			"DSUNMIS1"  = component.getRawProduct()?.getMeasurementUnit()?.getId(),
			"CPROWNUM" = 0,
			"CPROWORD" = 0,
			"DSTIPRIG" = "R"
		};

		return componente;
	}

	private function prepareExportData( required com.apirone.core.model.bean.Quotation quotation ){
		var result = {
			"data" = {},
			"error" = null
		};
		var quotationPrice = getQuotationPriceService().calculate( quotation.getId() );
		var customer = quotation.getCustomer();

//		if (isNull(quotation.getShippingProfile())) {
//			result.error = "Dati spedizione non trovati."
//			return result;
//		}
		var quotationData = {
			"MMSERIAL" = quotation.getSerial(), // i need the same code
			"MM_IDRIF" = quotation.getQuotationNumber(), // i need the same code
			"MMNUMDOC" = quotation.getQuotationNumber() & "/" & quotation.getVersionNumber(),
			"MMDATDOC" = quotation.getCreatedAt(),
			"MMDATEVA" = quotation.getValidityDate(),
			"MMRIFORD" = !IsNull( quotation.getOpportunity() ) ? quotation.getOpportunity().getName() : "",
			"MMNUMLIS" = 1,
			"MMCODAGE" = (!isNull(quotation.getSalesAgent())) ? quotation.getSalesAgent().getAccount().getEmail() : null, //trovata tabella AZAPI_AGENTI campo id AGECOD, campo mail AGEMAI
			"MMCODPAG" = quotation.getPaymentMethod().getId(),
			"MMCODVAL" = quotation.getCurrency().getId(),
			"CF_IDCLI" = customer.getId(),
			"CF___CAP" = customer.getPostalCode(),
			"CFDESCR1" = customer.getCompany(),
			"CFINDIRI" = customer.getStreet(),
			"CFLOCALI" = customer.getCity(),
			"CFPROVIN" = customer.getState(),
			"CFSTAISO" = customer.getCountry()?.getIsoCode(),
			"CFPARIVA" = customer.getVatNumber(),
			"CFTELEFO" = customer.getPhone(),
			"CFBLOCCO" = "N",
			"CFMOROSO" = "N",
			"MMSCOCF1" = quotationPrice.getDiscount1(),
			"MMSCOCF2" = quotationPrice.getDiscount2(),
			"MMSPETRA" = quotationPrice.getShippingCost(),
			"DECAPDES" = customer.getPostalCode(),
			"DEDESDOD" = customer.getCompany(),
			"DEINDDOD" = customer.getStreet(),
			"DELOCDOD" = customer.getCity(),
			"DEPRODOD" = customer.getState(),
			"DENAZDOD" = customer.getCountry()?.getIsoCode(),
		};

		if (isNull(quotation.getShippingProfile())) {
			quotationData["DECAPDOC"] = "";
			quotationData["DEIDDMER"] = "";
			quotationData["DEDESMER"] = "";
			quotationData["DEINDMER"] = "";
			quotationData["DELOCMER"] = "";
			quotationData["DEPROMER"] = "";
			quotationData["DENAZMER"] = "";
		} else {
			quotationData["DECAPDOC"] = quotation.getShippingProfile().getPostalCode();
			quotationData["DEIDDMER"] = quotation.getShippingProfile().getId();
			quotationData["DEDESMER"] = quotation.getShippingProfile().getCompany();
			quotationData["DEINDMER"] = quotation.getShippingProfile().getStreet();
			quotationData["DELOCMER"] = quotation.getShippingProfile().getCity();
			quotationData["DEPROMER"] = quotation.getShippingProfile().getState();
			quotationData["DENAZMER"] = quotation.getShippingProfile().getCountry()?.getIsoCode();
		}


		result.data = quotationData;
		return result;
	}

	public String function clone( required com.apirone.core.model.bean.Quotation quotation ){
		var originalQuotation = arguments.quotation;
		var clonedQuotation = Duplicate( originalQuotation );
		clonedQuotation.setId( "" );
		var clonedQuotationId = create( clonedQuotation, session.user.getId(), true );

		var quotationZones = getQuotationZoneService().list( quotationId = originalQuotation.getId() );

		for ( var quotationZone in quotationZones ) {
			getQuotationZoneService().duplicate( zoneId = quotationZone.getId(), quotationId = clonedQuotationId )
		}

		quotationService.update( originalQuotation );

		super.getCacheManager().remove( getCacheScope(), clonedQuotationId );
		super.getCacheManager().remove( getCacheScope(), arguments.quotation.getId() );

		return clonedQuotationId;
	}

	public String function promoteStatus( required com.apirone.core.model.bean.Quotation quotation ){
		var originalQuotation = arguments.quotation;
		var clonedQuotation = Duplicate( originalQuotation );
		clonedQuotation.setId( "" );
		clonedQuotation.setActive( 0 );
		clonedQuotation.setQuotationNumber( originalQuotation.getQuotationNumber() );
		clonedQuotation.setVersionNumber( originalQuotation.getVersionNumber() );
		var clonedQuotationId = create( clonedQuotation, session.user.getId(), false, true );

		var quotationZones = getQuotationZoneService().list( quotationId = originalQuotation.getId() );

		for ( var quotationZone in quotationZones ) {
			getQuotationZoneService().duplicate( zoneId = quotationZone.getId(), quotationId = clonedQuotationId )
		}

		originalQuotation.setVersionNumber( originalQuotation.getVersionNumber() + 1 );
		quotationService.update( originalQuotation );

		super.getCacheManager().remove( getCacheScope(), clonedQuotationId );
		super.getCacheManager().remove( getCacheScope(), arguments.quotation.getId() );

		return clonedQuotationId;
	}

	public Void function removeCache( required String quotationId ){

		super.getCacheManager().remove( getCacheScope(), arguments.quotationId );

	}

	/*
		private method
	*/

	private Void function notifyProductsVerticale(){

		cfhttp( url = "http://194.183.87.112:8080/verticale_web_data/servlet/api/v1/apir_update_articoli/ALL", method = "POST", result="result" ) {
			cfhttpparam( type = "header", name = "Content-Type", value = "application/json" );
			cfhttpparam( type = "header", name = "Authorization", value = "Basic #variables.verticaleSecret#" );
		}

		cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# notifyVerticale: apir_update_articoli: status: #result.status_code#");

	}

	private Void function notifyOrdersVerticale(){

		var user = "apikey";
		var pwd = "Gs16072001!";
		var secret = ToBase64('#user#:#pwd#');

		cfhttp( url = "http://194.183.87.112:8080/verticale_web_data/servlet/api/v1/apir_update_ordini/ALL", method = "POST", result="result" ) {
			cfhttpparam( type = "header", name = "Content-Type", value = "application/json" );
			cfhttpparam( type = "header", name = "Authorization", value = "Basic #variables.verticaleSecret#" );
		}

		cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# notifyVerticale: apir_update_ordini: status: #result.status_code#");

	}

	private com.apirone.core.model.bean.Quotation function build( required String quotationId ){
		var record = getDao().read( arguments.quotationId );

		if ( record.recordCount ) {
			var bean = super.bean( "Quotation" );

			var calculatedAmount = 0;

			bean.setId( record.quotation_id.toString() );
			bean.setSerial( record.serial );
			bean.setName( record.quotation );
			bean.setQuotationNumber( record.quotation_number );
			bean.setVersionNumber( record.version_number );
			bean.setQuotationDate( record.quotation_date );
			bean.setCreatedAt( record.created_at );
			bean.setNote( record.note );
			bean.setValidityDate( record.validity_date );
			bean.setExported( record.exported );
			bean.setActive( record.active );
			bean.setLang( getLangService().get( record.lang_id ) );
			bean.setCurrency( getCurrencyService().get( record.currency_id ) );
			bean.setOwner( getUserService().get( record.owner_id.toString() ) );
			bean.setPaymentMethod( getPaymentMethodService().get( record.payment_method_id ) );

			//by a trigger from history
			//bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setStatusHistory( getQuotationStatusHistoryService().get( record.quotation_status_history_id ) );

			if ( !IsNull( record.customer_id ) ) {

				var customer = getCustomerService().get( record.customer_id );
				bean.setCustomer( customer );

				// cerco l'indirizzo di spedizione tra gli indirizzi del customer
				if ( !IsNull( record.shipping_profile_id ) ) {
					for( var thisAddress in customer.getShippingProfiles() ) {
						if ( thisAddress.getId() == record.shipping_profile_id ) {
							bean.setShippingProfile( thisAddress );
							break;
						}
					}
				}

			}

			/*
			var quotationStatusHistories = getQuotationStatusHistoryService().list( quotationId = record.quotation_id, statusId = record.status_id );

			if ( quotationStatusHistories.len() > 0 && record.status_id == 'CCN' ) {
				var statusFiles = getFileService().list( quotationStatusHistoryId = quotationStatusHistories[1].getId() );
				if ( statusFiles.len() > 0 ) {
					bean.setStatusFile( statusFiles[1] )
				}
			}
			*/

			if ( !IsNull( record.opportunity_id ) ) {
				bean.setOpportunity( getOpportunityService().get( record.opportunity_id.toString() ) );
			}

			if ( !IsNull( record.lead_id ) ) {
				bean.setLead( getLeadService().get( record.lead_id ) );
			}

			if ( !IsNull( record.vat_code_id ) ) {
				bean.setVatCode( getVatCodeService().get( record.vat_code_id ) );
			}

			if ( !IsNull( record.sales_agent_account_id ) ) {
				bean.setSalesAgent( getUserService().get( record.sales_agent_account_id.toString() ) );
			}

			if ( !IsNull( record.graphic_technician_account_id ) ) {
				bean.setGraphicTechnician( getUserService().get( record.graphic_technician_account_id.toString() ) );
			}

			bean.setCalculatedAmount(
				getDao().getQuotationTotal( argumentCollection = { quotationId = bean.getId() } )
			);

			// bean.setPricelist( getPricelistService().get( record.pricelist_id ) );
			// bean.setBillingProfile( getProfileService().get( record.billing_profile_id ) );
			// bean.setgraphicTechnician( getAccountService().get( record.graphic_technician_account_id ) );

			return bean;
		}

		return NullValue();
	}

}
