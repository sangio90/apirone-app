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
	property name="accountService" inject="AccountService";

	public com.apirone.core.model.bean.Quotation function get( required String quotationId ){
		return build( arguments.quotationId );
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

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.quotation_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.quotation_id ] );
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
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotation" );
				outcome.setMessage( "Cannot delete quotation [#arguments.quotationId#]" );
				rethrow
			}


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

		return arguments.quotation.getId();
	}

	public Struct function exportProducts( required com.apirone.core.model.bean.QuotationItem[] quotationItems ){

		var result = {
			"success" = true,
			"error" = null,
			"exportedItems" = [],
			"skippedItems" = []
		};

		transaction {
			if ( arguments.quotationItems.len() ) {

				// --- Fase 1: pre-raccolta degli ID da tutti i quotationItem per il caricamento batch ---
				// Le tuple memorizzate verranno poi usate nella fase 2 per l'assemblaggio senza chiamate get() individuali.
				var exportTuples        = [];
				var allProductIds       = [];
				var allCategoryIds      = [];
				var allLineIds          = [];
				var allModelIds         = [];
				var allFinishIds        = [];
				var allProductItemIds   = [];
				var allFruitProductIds  = [];
				var allSignConfigItemIds = [];
				var allSignConfigIds    = [];

				for ( var quotationItem in arguments.quotationItems ) {
					// Gli articoli (servizi) non hanno dati prodotto - saltati nella pre-raccolta
					if ( !IsNull( quotationItem.getArticle() ) ) {
						continue;
					}

					if ( IsNull( quotationItem.getHash() ) || Trim( quotationItem.getHash() ) == "" ) {
						continue;
					}

					var productHash = getProductHashService().getByHash( quotationItem.getHash() );
					if ( IsNull( productHash ) ) {
						continue;
					}

					var existingCode = exportCodeService.list( "productHashId" = productHash.getId() );
					if ( existingCode.len() > 0 ) {
						continue;
					}

					var quotationItemData = deserializeJson( productHash.getJsonData() );

					// Raccoglie tutti gli ID unici per il caricamento batch
					ArrayAppend( allProductIds, quotationItemData.productId );
					ArrayAppend( allCategoryIds, quotationItemData.categoryId );
					ArrayAppend( allLineIds, quotationItemData.lineId );
					ArrayAppend( allModelIds, quotationItemData.modelId );
					ArrayAppend( allFinishIds, quotationItemData.finishId );

					if ( StructKeyExists( quotationItemData, "productItems" ) ) {
						for ( var pi in quotationItemData.productItems ) {
							ArrayAppend( allProductItemIds, pi.productItemId );
						}
					}

					if ( StructKeyExists( quotationItemData, "signageRows" ) && StructKeyExists( quotationItemData, "signageConfigItemId" ) ) {
						ArrayAppend( allSignConfigItemIds, quotationItemData.signageConfigItemId );
					}

					if ( StructKeyExists( quotationItemData, "fruits" ) ) {
						for ( var fruit in quotationItemData.fruits ) {
							ArrayAppend( allFruitProductIds, fruit.product );
							if ( StructKeyExists( fruit, "productItems" ) ) {
								for ( var fi in fruit.productItems ) {
									ArrayAppend( allProductItemIds, fi.productItemId );
								}
							}
						}
					}

					// Memorizza la tupla per la fase 2: item originale, dati deserializzati e productHash
					ArrayAppend( exportTuples, {
						item = quotationItem,
						data = quotationItemData,
						hash = productHash
					} );
				}

				// --- Fase 2: caricamento batch di tutte le entity ---
				// Carica i Product con getMany() ottimizzato (incluse tutte le sub-entity: categorie, testi, prezzi, file, attributi)
				var productMap = {};
				if ( ArrayLen( allProductIds ) ) {
					productMap = getProductService().getMany( allProductIds );
				}

				// Carica ProductCategory, Line, Model, Finish con i rispettivi getMany()
				var categoryMap = {};
				if ( ArrayLen( allCategoryIds ) ) {
					categoryMap = getProductCategoryService().getMany( allCategoryIds );
				}

				var lineMap = {};
				if ( ArrayLen( allLineIds ) ) {
					lineMap = getLineService().getMany( allLineIds );
				}

				var modelMap = {};
				if ( ArrayLen( allModelIds ) ) {
					modelMap = getModelService().getMany( allModelIds );
				}

				var finishMap = {};
				if ( ArrayLen( allFinishIds ) ) {
					finishMap = getFinishService().getMany( allFinishIds );
				}

				var productItemMap = {};
				if ( ArrayLen( allProductItemIds ) ) {
					productItemMap = getProductItemService().getMany( allProductItemIds );
				}

				// Carica anche i fruit product (sono Product, ma con ID separato)
				var fruitProductMap = {};
				if ( ArrayLen( allFruitProductIds ) ) {
					fruitProductMap = getProductService().getMany( allFruitProductIds );
				}

				// Carica SignageConfigItem e SignageConfig in batch
				var signConfigItemMap = {};
				if ( ArrayLen( allSignConfigItemIds ) ) {
					signConfigItemMap = getSignageConfigItemService().getMany( allSignConfigItemIds );
				}

				// Raccoglie i signage_config_id dai SignageConfigItem caricati per il caricamento batch delle config
				for ( var scid in allSignConfigItemIds ) {
					if ( StructKeyExists( signConfigItemMap, scid ) ) {
						ArrayAppend( allSignConfigIds, signConfigItemMap[ scid ].getSignageConfigId() );
					}
				}
				var signConfigMap = {};
				if ( ArrayLen( allSignConfigIds ) ) {
					signConfigMap = getSignageConfigService().getMany( allSignConfigIds );
				}

				// --- Fase 3a: elaborazione degli articoli (servizi) ---
				for ( var quotationItem in arguments.quotationItems ) {
					if ( IsNull( quotationItem.getArticle() ) ) {
						continue;
					}

					var isSpeciale = quotationItem.getSpecial() ? "S" : "N";

					var dataExport = {
						"AR_CHIAVE" = quotationItem.getArticle().getCode() & RepeatString( "0", 31 - Len( quotationItem.getArticle().getCode() ) ),
						"ARCODART"  = quotationItem.getArticle().getCode() & RepeatString( "0", 15 - Len( quotationItem.getArticle().getCode() ) ),
						"ARDESART"  = quotationItem.getArticle().getDescription().subString( 0, Len( quotationItem.getArticle().getDescription() ) ) & RepeatString(
							"0",
							35 - Len( quotationItem.getArticle().getDescription().subString( 0, Len( quotationItem.getArticle().getDescription() ) ) )
						),
						"ARDESSUP"  = "",
						"ARDATCAR"  = Now(),
						"ARUNMIS1"  = "PZ",
						"VARCOD"    = "0000000000",
						"VARNOT"    = "",
						"CLCODICE"  = "000000",
						"CLANNOTA"  = quotationItem.getNote(),
						"ARIMG_64"  = "",
						"ARSPECIA"  = isSpeciale,
						"ARCODNOM"  = ""
					};

					// non abbiamo un prodotto legato a questa riga, quindi cerchiamo per codice e basta tra i codici gia esportati.
					var existingCodes = exportCodeService.list(
						str = quotationItem.getArticle().getCode() & RepeatString( "0", 25 - Len( quotationItem.getArticle().getCode() ) )
					);

					if ( existingCodes.len() > 0 ) {
						ArrayAppend( result.skippedItems, quotationItem.getArticle().getCode() );
						continue;
					}

					var exportCode = super.bean( "ExportCode" );
					exportCode.setName( quotationItem.getArticle().getCode() & RepeatString( "0", 25 - Len( quotationItem.getArticle().getCode() ) ) );
					exportCode.setCounter( "000000" );
					exportCodeService.create( "exportCode" = exportCode );
					result.success = getDao().exportProduct( dataExport );
					ArrayAppend( result.exportedItems, quotationItem.getArticle().getCode() );
				}

				// --- Fase 3b: elaborazione dei prodotti usando esclusivamente le mappe batch ---
				for ( var tuple in exportTuples ) {
					var quotationItem     = tuple.item;
					var quotationItemData = tuple.data;
					var productHash       = tuple.hash;

					var isSpeciale = quotationItem.getSpecial() ? "S" : "N";

					var hsCode = "";
					try {
						hsCode = quotationItem.getProduct().getLine().getHscode();
					} catch ( any e ) {
					}

					var quotationImageFile = quotationItem.getImage();
					var base64File         = "";

					try {
						var path = ExpandPath( "/../repository/public/media/quotation-items/500/" & quotationImageFile.getDirectory() & "/" & quotationImageFile.getName() );
						var file = FileReadBinary( path );
						if ( !IsNull( file ) ) {
							base64File = ToBase64( file );
						}
					} catch ( any e ) {
					}

					var code = "";

					// Recupera il prodotto e la categoria dalla mappa batch (con fallback individuale difensivo)
					var product = StructKeyExists( productMap, quotationItemData.productId )
						? productMap[ quotationItemData.productId ]
						: getProductService().get( quotationItemData.productId );
					var category = StructKeyExists( categoryMap, quotationItemData.categoryId )
						? categoryMap[ quotationItemData.categoryId ]
						: getProductCategoryService().get( quotationItemData.categoryId );
					if ( IsNull( product ) || IsNull( category ) ) {
						result.success = false;
						result.error   = 'Prodotto o Categoria Prodotto non trovata.';
						return result;
					}

					var categoryCode = Trim( category.getCode() );
					code &= categoryCode;
					var note = "";

					var line = StructKeyExists( lineMap, quotationItemData.lineId )
						? lineMap[ quotationItemData.lineId ]
						: getLineService().get( quotationItemData.lineId );
					if ( IsNull( line ) ) {
						result.success = false;
						result.error   = "Linea prodotto non trovata.";
						return result;
					}
					var lineCode = Trim( line.getCode() );
					code &= lineCode;

					var model = StructKeyExists( modelMap, quotationItemData.modelId )
						? modelMap[ quotationItemData.modelId ]
						: getModelService().get( quotationItemData.modelId );
					if ( IsNull( model ) ) {
						result.success = false;
						result.error   = "Modello prodotto non trovato.";
						return result;
					}
					code &= Trim( model.getCode() );

					var finish = StructKeyExists( finishMap, quotationItemData.finishId )
						? finishMap[ quotationItemData.finishId ]
						: getFinishService().get( quotationItemData.finishId );
					if ( IsNull( finish ) ) {
						result.success = false;
						result.error   = "Finitura prodotto non trovata.";
						return result;
					}
					var finishCode = Trim( finish.getCode() );
					code &= finishCode;

					var description = product.getDescription().left( 35 );

					var arKey           = code;
					var colCode         = "000000";
					var varCode         = "";
					var noteSegnaletica = '';

					// Segnaletica: recupera SignageConfigItem e SignageConfig dalle mappe batch
					if ( StructKeyExists( quotationItemData, "signageRows" ) ) {
						var signageConfigItem = StructKeyExists( signConfigItemMap, quotationItemData.signageConfigItemId )
							? signConfigItemMap[ quotationItemData.signageConfigItemId ]
							: getSignageConfigItemService().get( quotationItemData.signageConfigItemId );
						var fontSize     = signageConfigItem.getSize().getName();
						var signageConfigId = signageConfigItem.getSignageConfigId();
						var signageConfig = StructKeyExists( signConfigMap, signageConfigId )
							? signConfigMap[ signageConfigId ]
							: getSignageConfigService().get( signageConfigId );
						var fontCode     = signageConfig.getFont().getCode();
						var fontName     = signageConfig.getFont().getName();
						note &= "Font: " & fontName & "; Font Size: " & fontSize & "; ";
						varCode = right( "00000" & fontCode, 5 ) & right( "00000" & fontSize, 5 );
						var signageRowsCounter = 1;
						for ( var signageRow in quotationItemData.signageRows ) {
							noteSegnaletica &= 'riga ' & signageRowsCounter & ': Allineamento: ' & signageRow[ 'text-align' ] & ': Testo: "' & signageRow.content & '"";';
							signageRowsCounter++;
						}
					}

					var productItemIds     = [];
					var productItems       = [];
					var importantAttributes = product.getImportantAttributes();
					for ( var quotationItemProductItem in quotationItemData.productItems ) {
						var productItem = StructKeyExists( productItemMap, quotationItemProductItem.productItemId )
							? productItemMap[ quotationItemProductItem.productItemId ]
							: getProductItemService().get( quotationItemProductItem.productItemId );
						if ( !IsNull( productItem ) ) {
							var attributeValue = productItem.getAttributeValue();
							// attributeService.get() è mantenuto come chiamata individuale:
							// l'attributeId proviene dal ProductItem già caricato, non è pre-raccoglibile.
							var attribute = attributeService.get( attributeId = attributeValue.getAttributeId() );

							if ( IsNull( attribute ) ) {
								result.success = false;
								result.error   = 'Attributo Prodotto non trovato.';
								return result;
							}
							var rawValue = attributeValue.getRawValue();

							var isImportant = false;
							if ( !IsNull( importantAttributes ) ) {
								isImportant = importantAttributes.some( function( item ){
									return item.getId() == attribute.getId();
								} );
							}

							if ( isImportant ) {
								var slotCode = Trim( attribute.getCode() ) & Trim( rawValue.getCode() );
								if ( varCode.len() + slotCode.len() > 10 ) {
									result.success = false;
									result.error = 'Il codice variante supera i 10 caratteri: attributo "'
										& Trim( attribute.getCode() )
										& '" (valore "'
										& Trim( rawValue.getCode() )
										& '") non entra nel codice variante (già '
										& varCode.len()
										& ' su 10 caratteri). Verificare i codici degli attributi importanti del prodotto.';
									return result;
								}

								varCode &= slotCode;
								arrayAppend( productItems, {
									"important"   = true,
									"rawValueId"  = rawValue.getId(),
									"attributeId" = attributeValue.getAttributeId()
								} );
							} else {
								arrayAppend( productItems, {
									"important"   = false,
									"rawValueId"  = rawValue.getId(),
									"attributeId" = attributeValue.getAttributeId()
								} );
							}
							arrayAppend( productItemIds, productItem.getId() );
						}

						note &= attribute.getName() & ": " & rawValue.getName() & "; ";
					}

					var productComponents = getComponents( product.getId(), quotationItem, productItemIds );
					varCode &= RepeatString( "0", 10 - Len( varCode ) );

					// Placca: recupera i fruit product e i productItem dalle mappe batch
					var fruitsComponents     = [];
					var fruitsProductItems   = {};
					var fruitsProductItemIds = {};
					if ( StructKeyExists( quotationItemData, "fruits" ) ) {
						var orientation = quotationItem.getFrame().getOrientation().getName();
						note &= "Orientamento: " & orientation & ";";

						var fruits = quotationItemData.fruits;
						if ( Len( fruits ) ) {
							note &= " Frutti: ";
						}
						var fruitsIndex = 1;
						for ( var fruit in fruits ) {
							var fruitBean = StructKeyExists( fruitProductMap, fruit.product )
								? fruitProductMap[ fruit.product ]
								: getProductService().get( fruit.product );
							note &= " " & fruitBean.getCode();
							var fruitItems = fruit.productItems;
							fruitsProductItems[ fruitsIndex ]     = [];
							fruitsProductItemIds[ fruitsIndex ]   = [];
							if ( Len( fruitItems ) ) {
								note &= ": ";
								for ( var fruitItem in fruitItems ) {
									var fruitItemBean = StructKeyExists( productItemMap, fruitItem.productItemId )
										? productItemMap[ fruitItem.productItemId ]
										: getProductItemService().get( fruitItem.productItemId );
									var attributeValue = fruitItemBean.getAttributeValue();
									var attribute      = attributeService.get( attributeId = attributeValue.getAttributeId() );

									if ( IsNull( attribute ) ) {
										result.success = false;
										result.error   = 'Attributo Frutto non trovato.';
										return result;
									}
									var rawValue = attributeValue.getRawValue();
									arrayAppend( fruitsProductItems[ fruitsIndex ], {
										"important"   = false,
										"rawValueId"  = rawValue.getId(),
										"attributeId" = attributeValue.getAttributeId()
									} );
									arrayAppend( fruitsProductItemIds[ fruitsIndex ], fruitItemBean.getId() );
									note &= attribute.getName() & ": " & rawValue.getName() & "; ";
									if ( fruitItem.note != "" ) {
										note &= " Note: " & fruitItem.note & "; ";
									}
								}
							}
							arrayAppend( fruitsComponents, getComponents( fruit.product, quotationItem, fruitsProductItemIds[ fruitsIndex ] ) );
							fruitsIndex++;
						}
					}

					var exportCode = super.bean( "ExportCode" );
					exportCode.setName( code & varCode );
					exportCode.setProductHashId( productHash.getId() );
					var maxCounter = exportCodeService.max( exportCode = code & varCode );
					if ( maxCounter > 0 ) {
						var newMaxCounter = NumberFormat( maxCounter + 1, "000000" );
						exportCode.setCounter( newMaxCounter );
						colCode = newMaxCounter;
					} else {
						exportCode.setCounter( "000001" );
						colCode = "000001";
					}
					exportCodeService.create( "exportCode" = exportCode );

					arKey = code & varCode & colCode;
					var dataExport = {
						"AR_CHIAVE" = arKey,
						"ARCODART"  = code & RepeatString( "0", 15 - Len( code ) ),
						"ARDESART"  = description,
						"ARDESSUP"  = quotationItemData.special == 'true' ? 'SÌ DWG' : 'NO DWG',
						"ARDATCAR"  = Now(),
						"ARUNMIS1"  = "PZ",
						"VARCOD"    = varCode,
						"VARNOT"    = noteSegnaletica,
						"CLCODICE"  = colCode,
						"CLANNOTA"  = note,
						"ARIMG_64"  = base64File,
						"ARSPECIA"  = isSpeciale,
						"ARCODNOM"  = hsCode
					};

					result.success = getDao().exportProduct( dataExport );
					ArrayAppend( result.exportedItems, description );

					var allComponents = [];
					for ( var productComponent in productComponents ) {
						productComponent.DS_CHIAVE = dataExport.AR_CHIAVE;
						productComponent.DSCODART  = dataExport.ARCODART;
						productComponent.DSCODVAR  = dataExport.VARCOD;
						productComponent.DSCODCOL  = dataExport.CLCODICE;
						ArrayAppend( allComponents, productComponent );
					}

					if ( StructKeyExists( quotationItemData, "fruits" ) ) {
						for ( var fruitComponents in fruitsComponents ) {
							for ( var fruitComponent in fruitComponents ) {
								fruitComponent.DS_CHIAVE = dataExport.AR_CHIAVE;
								fruitComponent.DSCODART  = dataExport.ARCODART;
								fruitComponent.DSCODVAR  = dataExport.VARCOD;
								fruitComponent.DSCODCOL  = dataExport.CLCODICE;
								ArrayAppend( allComponents, fruitComponent );
							}
						}
					}

					var grouped = {};
					for ( var row in allComponents ) {
						var key = row.DSCODMAT & "|" & row.DSVARMAT & "|" & row.DSCOLMAT;
						if ( !structKeyExists( grouped, key ) ) {
							grouped[ key ]             = duplicate( row );
							grouped[ key ].DSQTAMOV    = val( row.DSQTAMOV );
						} else {
							grouped[ key ].DSQTAMOV += val( row.DSQTAMOV );
						}
					}
					var parsedComponents = [];
					for ( var key in grouped ) {
						arrayAppend( parsedComponents, grouped[ key ] );
					}

					var counter = 0;
					for ( var row in parsedComponents ) {
						counter++;
						row.CPROWNUM = counter;
						row.CPROWORD = counter * 10;
						row.DSDATCRE = DateFormat( now(), "yyyy-mm-dd" );
						result.success = getDao().exportDiba( row );
					}
				}
			}
		}

		return result;
	}

	public Struct function export( required com.apirone.core.model.bean.QuotationItem[] quotationItems, boolean provisional = false ){
		var result = {
			'success' = false,
			'error' = null
		};

		transaction {
			if (quotationItems.len() > 0) {
				var quotation = quotationItems[1].getQuotation();

				getDao().deleteExport( quotationNumber = quotation.getQuotationNumber() );
				quotationDataResult = prepareExportData(quotation, arguments.provisional);
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

	public Array function getComponents(
		required String productId,
		required quotationItem,
		Array productItemIds = []
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
				ArrayAppend( allComponents, parseComponent( bundleComponent ) );
			}

			if ( IsInstanceOf( quotationItem, "com.apirone.core.model.bean.QuotationItemSignage" ) ) {
				var signageConfigItemId = quotationItem.getSignageConfigItem().getId();

				var signageComponents = componentSvc.list(
					signageConfigItemId            = signageConfigItemId,
					includeBaseAttributeComponents = true
				);

				if ( productItemIds.len() > 0 ) {
					var signageProductComps = componentSvc.listBySignageItemProductJoinIds(
						signageConfigItemId = signageConfigItemId,
						productItemIds      = productItemIds
					);
					for ( var spc in signageProductComps ) {
						ArrayAppend( allComponents, parseComponent( spc ) );
					}
				}

				for ( var signageComponent in signageComponents ) {
					ArrayAppend( allComponents, parseComponent( signageComponent ) );
				}
			}
		}

		var productComponents = componentSvc.list( productId = product.getId(), includeBaseAttributeComponents = true );

		for ( var productComponent in productComponents ) {
			ArrayAppend( allComponents, parseComponent( productComponent ) );
		}

		if ( productItemIds.len() > 0 ) {
			// Own components: batch con listByProductItemIds()
			var ownComponents = componentSvc.listByProductItemIds( productItemIds );
			for ( var oc in ownComponents ) {
				ArrayAppend( allComponents, parseComponent( oc ) );
			}

			// Base attribute components: corrisponde a includeBaseAttributeComponents=true
			// dell'originale searchByProductItemId() in ComponentService
			var compDao = componentSvc.getDao();
			var piMap   = getProductItemService().getMany( productItemIds );
			var attrValueIds = [];

			for ( var pid in productItemIds ) {
				if ( StructKeyExists( piMap, pid ) ) {
					var piBean  = piMap[ pid ];
					var attrVal = piBean.getAttributeValue();
					if ( !IsNull( attrVal ) && Len( attrVal.getId() ) ) {
						ArrayAppend( attrValueIds, attrVal.getId() );
					}
				}
			}

			if ( ArrayLen( attrValueIds ) ) {
				var attrRecords = compDao.readByAttributeValueIds( attrValueIds );

				// Raggruppa i componenti per attribute_raw_value_id
				var attrValueToCompIds = {};
				for ( var ar in attrRecords ) {
					if ( !StructKeyExists( attrValueToCompIds, ar.attribute_raw_value_id ) ) {
						attrValueToCompIds[ ar.attribute_raw_value_id ] = [];
					}
					ArrayAppend( attrValueToCompIds[ ar.attribute_raw_value_id ], ar.component_id );
				}

				// Raccoglie tutti i component ID e carica i bean con getMany()
				var allAttrCompIds = [];
				for ( var avid in attrValueToCompIds ) {
					for ( var cid in attrValueToCompIds[ avid ] ) {
						ArrayAppend( allAttrCompIds, cid );
					}
				}

				if ( ArrayLen( allAttrCompIds ) ) {
					var attrBeanMap = componentSvc.getMany( allAttrCompIds );

					for ( var pid in productItemIds ) {
						if ( !StructKeyExists( piMap, pid ) ) {
							continue;
						}
						var piBean  = piMap[ pid ];
						var attrVal = piBean.getAttributeValue();
						if ( IsNull( attrVal ) || !Len( attrVal.getId() ) ) {
							continue;
						}
						// Recupera solo i componenti dell'attributo di QUESTO specifico productItemId
						var myAttrCompIds = StructKeyExists( attrValueToCompIds, attrVal.getId() )
							? attrValueToCompIds[ attrVal.getId() ]
							: [];

						for ( var acid in myAttrCompIds ) {
							if ( !StructKeyExists( attrBeanMap, acid ) ) {
								continue;
							}
							var attrComp = attrBeanMap[ acid ];

							// Costruisce wrapper ComponentProductItem con type "base",
							// replicando la logica di searchByProductItemId() in ComponentService
							var baseBean = super.bean( "ComponentProductItem" );
							baseBean.setRawMemento( attrComp.getRawMemento() );
							baseBean.setProductItem( piBean );
							baseBean.setTypeId( "base" );

							var overrideSvc = componentSvc.getComponentOverrideService();
							var override    = overrideSvc.list( piBean.getId(), attrComp.getId() );
							if ( ArrayLen( override ) ) {
								baseBean.setOverride( override[ 1 ] );
							}

							ArrayAppend( allComponents, parseComponent( baseBean ) );
						}
					}
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

	private function prepareExportData( required com.apirone.core.model.bean.Quotation quotation, boolean provisional = false ){
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
			"MMDATEVA" = !isNull(quotation.getDataEvasione()) ? quotation.getDataEvasione() : javaCast("null", ""),
			"MMEVASIO" = !isNull(quotation.getDataEvasione()) ? quotation.getDataEvasione() : javaCast("null", ""),
			"MMRIFORD" = quotation.getRifLibero() ?: "",
			"MMNUMLIS" = 1,
			"CFLINGUA" = !isNull(quotation.getLang()) ? UCase(quotation.getLang().getId()) : "IT",
			"MMCODAGE" = (!isNull(quotation.getAgente1()) && Len(quotation.getAgente1())) ? getAccountService().get(quotation.getAgente1()).getIdAgenteVerticale() : null,
			"MMCODAG2" = (!isNull(quotation.getAgente2()) && Len(quotation.getAgente2())) ? getAccountService().get(quotation.getAgente2()).getIdAgenteVerticale() : null,
			"MMCODAG3" = (!isNull(quotation.getAgente3()) && Len(quotation.getAgente3())) ? getAccountService().get(quotation.getAgente3()).getIdAgenteVerticale() : null,
			"MMCODAG4" = (!isNull(quotation.getAgente4()) && Len(quotation.getAgente4())) ? getAccountService().get(quotation.getAgente4()).getIdAgenteVerticale() : null,
			"MMCODAG5" = (!isNull(quotation.getAgente5()) && Len(quotation.getAgente5())) ? getAccountService().get(quotation.getAgente5()).getIdAgenteVerticale() : null,
			"MMPERPRO" = !isNull(quotation.getCommission1()) ? quotation.getCommission1() : 0,
			"MMPERPR2" = !isNull(quotation.getCommission2()) ? quotation.getCommission2() : 0,
			"MMPERPR3" = !isNull(quotation.getCommission3()) ? quotation.getCommission3() : 0,
			"MMPERPR4" = !isNull(quotation.getCommission4()) ? quotation.getCommission4() : 0,
			"MMPERPR5" = !isNull(quotation.getCommission5()) ? quotation.getCommission5() : 0,
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
			"CFREFAMM" = quotation.getReferenteAmministrativo() ?: "",
			"MMRIFSPE" = quotation.getReferenteSpedizione() ?: "",
			"CFTIPCLF" = (function(){
				var crmToErp = {
					"CAT" = "CA", "HOT" = "HO", "HO1" = "H1", "HO2" = "H2", "HO3" = "H3",
					"HO4" = "H4", "HO5" = "H5", "BEB" = "BB", "RIS" = "RI", "AGR" = "AG",
					"CAM" = "CM", "AGE" = "AE", "CLI" = "CL", "RES" = "RS", "UFF" = "UF",
					"ARC" = "AR", "CEN" = "CN", "CON" = "CO", "RIV" = "RV", "IMC" = "IC",
					"COl" = "CP", "AZI" = "AZ", "PRO" = "PR", "COS" = "CS", "ELE" = "EL",
					"ENT" = "EN", "NEG" = "NE", "AGA" = "AA", "CCR" = "CC", "PRI" = "PI",
					"Installatore Elettrico" = "IE", "Tour Operator" = "TO", "Other" = "OT"
				};
				var ct = quotation.getCustomerType() ?: "";
				return StructKeyExists( crmToErp, ct ) ? crmToErp[ ct ] : "";
			})(),
			"INDUSTRY" = quotation.getIndustry() ?: "",
			"MMORDFOR" = "",
			"CFCODDES" = quotation.getCodiceSdi() ?: "",
			"MMORDPRO" = arguments.provisional ? "S" : "N",
			"MMSCOCF1" = quotationPrice.getDiscount1(),
			"MMSCOCF2" = quotationPrice.getDiscount2(),
			"MMSPETRA" = quotationPrice.getShippingCost(),
			"DECAPDOC" = customer.getPostalCode(),
			"DEDESDOD" = customer.getCompany(),
			"DEINDDOD" = customer.getStreet(),
			"DELOCDOD" = customer.getCity(),
			"DEPRODOD" = customer.getState(),
			"DENAZDOD" = customer.getCountry()?.getIsoCode(),
		};

		if (isNull(quotation.getShippingProfile())) {
			quotationData["DECAPDES"] = "";
			quotationData["DEIDDMER"] = "";
			quotationData["DEDESMER"] = "";
			quotationData["DEINDMER"] = "";
			quotationData["DELOCMER"] = "";
			quotationData["DEPROMER"] = "";
			quotationData["DENAZMER"] = "";
		} else {
			quotationData["DECAPDES"] = quotation.getShippingProfile().getPostalCode();
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
		clonedQuotation.setNote( "Copia di " & originalQuotation.getQuotationNumber() & "/" & originalQuotation.getVersionNumber() );
		var clonedQuotationId = create( clonedQuotation, session.user.getId(), true );

		var quotationZones = getQuotationZoneService().list( quotationId = originalQuotation.getId() );

		for ( var quotationZone in quotationZones ) {
			getQuotationZoneService().duplicate( zoneId = quotationZone.getId(), quotationId = clonedQuotationId )
		}

		quotationService.update( originalQuotation );

		return clonedQuotationId;
	}

	public String function promoteStatus( required com.apirone.core.model.bean.Quotation quotation ){
		var originalQuotation = arguments.quotation;
		var clonedQuotation = Duplicate( originalQuotation );
		clonedQuotation.setId( "" );
		clonedQuotation.setActive( 1 );
		clonedQuotation.setQuotationNumber( originalQuotation.getQuotationNumber() );
		clonedQuotation.setVersionNumber( getDao().readMaxVersionNumber( originalQuotation.getQuotationNumber() ) + 1 );
		var clonedQuotationId = create( clonedQuotation, session.user.getId(), false, true );

		var quotationZones = getQuotationZoneService().list( quotationId = originalQuotation.getId() );

		for ( var quotationZone in quotationZones ) {
			getQuotationZoneService().duplicate( zoneId = quotationZone.getId(), quotationId = clonedQuotationId )
		}

		return clonedQuotationId;
	}

	public Void function markAsSent( required String quotationId ){
		getDao().markAsSent( arguments.quotationId );
	}

	public String function createRevision( required com.apirone.core.model.bean.Quotation quotation ){
		var originalQuotation = arguments.quotation;
		var clonedQuotation   = Duplicate( originalQuotation );
		clonedQuotation.setId( "" );
		clonedQuotation.setActive( 1 );
		clonedQuotation.setSentToClient( false );
		clonedQuotation.setQuotationNumber( originalQuotation.getQuotationNumber() );
		clonedQuotation.setVersionNumber( getDao().readMaxVersionNumber( originalQuotation.getQuotationNumber() ) + 1 );
		var clonedQuotationId = create( clonedQuotation, session.user.getId(), false, true );

		var quotationZones = getQuotationZoneService().list( quotationId = originalQuotation.getId() );
		for ( var quotationZone in quotationZones ) {
			getQuotationZoneService().duplicate( zoneId = quotationZone.getId(), quotationId = clonedQuotationId );
		}

		return clonedQuotationId;
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

	/**
	 * Recupera in batch più Quotation dato un array di ID.
	 * Restituisce uno Struct chiave = quotationId, valore = bean Quotation.
	 * precarica User e QuotationStatusHistory in batch per evitare il problema N+1.
	 *
	 * @ids Array di quotationId
	 * @return Struct mappato per quotationId -> Quotation
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie tutti gli user_id (owner, salesAgent, graphicTechnician)
		var allUserIds = [];
		for ( var r in records ) {
			if ( !IsNull( r.owner_id ) ) {
				allUserIds.append( r.owner_id );
			}
			if ( !IsNull( r.sales_agent_account_id ) ) {
				allUserIds.append( r.sales_agent_account_id );
			}
			if ( !IsNull( r.graphic_technician_account_id ) ) {
				allUserIds.append( r.graphic_technician_account_id );
			}
		}

		// Precarica gli User in batch (1 query per tutti e 3 i ruoli)
		var userMap = {};
		if ( ArrayLen( allUserIds ) ) {
			userMap = getUserService().getMany( allUserIds );
		}

		// Raccoglie i quotation_status_history_id
		var statusHistoryIds = [];
		for ( var r in records ) {
			if ( !IsNull( r.quotation_status_history_id ) ) {
				statusHistoryIds.append( r.quotation_status_history_id );
			}
		}

		// Precarica i QuotationStatusHistory in batch (1 query)
		var statusHistoryMap = {};
		if ( ArrayLen( statusHistoryIds ) ) {
			statusHistoryMap = getQuotationStatusHistoryService().getMany( statusHistoryIds );
		}

		// Precarica i totali calcolati in batch (1 query invece di N)
		var quotationIds = [];
		for ( var r in records ) {
			quotationIds.append( r.quotation_id );
		}
		var totalMap = getDao().getQuotationTotals( quotationIds );

		// Costruisce i bean Quotation con le mappe pre-caricate
		for ( var r in records ) {
			var bean = super.bean( "Quotation" );

			// Campi diretti dal record
			bean.setId( r.quotation_id.toString() );
			bean.setSerial( r.serial );
			bean.setName( r.quotation );
			bean.setQuotationNumber( r.quotation_number );
			bean.setVersionNumber( r.version_number );
			bean.setQuotationDate( r.quotation_date );
			bean.setCreatedAt( r.created_at );
			bean.setNote( r.note );
			bean.setValidityDate( r.validity_date );
			bean.setExported( r.exported );
			bean.setActive( r.active );

			// Lang, Currency, PaymentMethod: chiamate individuali (cache interna)
			bean.setLang( getLangService().get( r.lang_id ) );
			bean.setCurrency( getCurrencyService().get( r.currency_id ) );
			bean.setPaymentMethod( getPaymentMethodService().get( r.payment_method_id ) );

			// Owner, SalesAgent, GraphicTechnician: dalla mappa batch
			if ( !IsNull( r.owner_id ) && StructKeyExists( userMap, r.owner_id ) ) {
				bean.setOwner( userMap[ r.owner_id ] );
			} else if ( !IsNull( r.owner_id ) ) {
				bean.setOwner( getUserService().get( r.owner_id.toString() ) );
			}

			if ( !IsNull( r.sales_agent_account_id ) && StructKeyExists( userMap, r.sales_agent_account_id ) ) {
				bean.setSalesAgent( userMap[ r.sales_agent_account_id ] );
			} else if ( !IsNull( r.sales_agent_account_id ) ) {
				bean.setSalesAgent( getUserService().get( r.sales_agent_account_id.toString() ) );
			}

			if ( !IsNull( r.graphic_technician_account_id ) && StructKeyExists( userMap, r.graphic_technician_account_id ) ) {
				bean.setGraphicTechnician( userMap[ r.graphic_technician_account_id ] );
			} else if ( !IsNull( r.graphic_technician_account_id ) ) {
				bean.setGraphicTechnician( getUserService().get( r.graphic_technician_account_id.toString() ) );
			}

			// StatusHistory: dalla mappa batch
			if ( !IsNull( r.quotation_status_history_id ) && StructKeyExists( statusHistoryMap, r.quotation_status_history_id ) ) {
				bean.setStatusHistory( statusHistoryMap[ r.quotation_status_history_id ] );
			}

			// Agenti e commissioni (campi diretti)
			bean.setNessunAgente( r.nessun_agente );
			if ( !IsNull( r.agente1 ) && Len( r.agente1 ) ) bean.setAgente1( r.agente1.toString() );
			if ( !IsNull( r.agente2 ) && Len( r.agente2 ) ) bean.setAgente2( r.agente2.toString() );
			if ( !IsNull( r.agente3 ) && Len( r.agente3 ) ) bean.setAgente3( r.agente3.toString() );
			if ( !IsNull( r.agente4 ) && Len( r.agente4 ) ) bean.setAgente4( r.agente4.toString() );
			if ( !IsNull( r.agente5 ) && Len( r.agente5 ) ) bean.setAgente5( r.agente5.toString() );
			if ( !IsNull( r.commission1 ) ) bean.setCommission1( r.commission1 );
			if ( !IsNull( r.commission2 ) ) bean.setCommission2( r.commission2 );
			if ( !IsNull( r.commission3 ) ) bean.setCommission3( r.commission3 );
			if ( !IsNull( r.commission4 ) ) bean.setCommission4( r.commission4 );
			if ( !IsNull( r.commission5 ) ) bean.setCommission5( r.commission5 );
			if ( Len( r.referente_amministrativo ) ) bean.setReferenteAmministrativo( r.referente_amministrativo );
			if ( Len( r.referente_spedizione ) ) bean.setReferenteSpedizione( r.referente_spedizione );
			if ( Len( r.customer_type ) ) bean.setCustomerType( r.customer_type );
			if ( Len( r.industry ) ) bean.setIndustry( r.industry );
			if ( Len( r.rif_libero ) ) bean.setRifLibero( r.rif_libero );
			if ( IsDate( r.data_evasione ) ) bean.setDataEvasione( r.data_evasione );
			if ( !IsNull( r.sent_to_client ) ) bean.setSentToClient( r.sent_to_client );
			if ( !IsNull( r.data_conferma_ordine ) && IsDate( r.data_conferma_ordine ) ) bean.setDataConfermaOrdine( r.data_conferma_ordine );
			if ( Len( r.codice_sdi ) ) bean.setCodiceSdi( r.codice_sdi );

			// Customer: chiamata individuale (CRM API, cache interna)
			if ( !IsNull( r.customer_id ) ) {
				var customer = getCustomerService().get( r.customer_id );
				bean.setCustomer( customer );

				if ( !IsNull( r.shipping_profile_id ) ) {
					for ( var thisAddress in customer.getShippingProfiles() ) {
						if ( thisAddress.getId() == r.shipping_profile_id ) {
							bean.setShippingProfile( thisAddress );
							break;
						}
					}
				}
			}

			// Opportunity, Lead, VatCode: chiamate individuali (CRM/verticale, cache interna)
			if ( !IsNull( r.opportunity_id ) ) {
				bean.setOpportunity( getOpportunityService().get( r.opportunity_id.toString() ) );
			}
			if ( !IsNull( r.lead_id ) ) {
				bean.setLead( getLeadService().get( r.lead_id ) );
			}
			if ( !IsNull( r.vat_code_id ) ) {
				bean.setVatCode( getVatCodeService().get( r.vat_code_id ) );
			}

			// Totale calcolato: dalla mappa batch
			bean.setCalculatedAmount(
				StructKeyExists( totalMap, r.quotation_id ) ? totalMap[ r.quotation_id ] : 0
			);

			map[ r.quotation_id ] = bean;
		}

		return map;
	}

	/**
	 * Costruisce un bean Quotation a partire dall'ID. Delega a buildFromRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.Quotation function build( required String quotationId ){
		var record = getDao().read( arguments.quotationId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Quotation a partire da una riga del query.
	 * Le sub-entity (Lang, Currency, Owner, PaymentMethod, StatusHistory, Customer, ecc.) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.Quotation function buildFromRow( required any record ){
		var bean = super.bean( "Quotation" );

		var calculatedAmount = 0;

		// Campi diretti dal record
		bean.setId( arguments.record.quotation_id.toString() );
		bean.setSerial( arguments.record.serial );
		bean.setName( arguments.record.quotation );
		bean.setQuotationNumber( arguments.record.quotation_number );
		bean.setVersionNumber( arguments.record.version_number );
		bean.setQuotationDate( arguments.record.quotation_date );
		bean.setCreatedAt( arguments.record.created_at );
		bean.setNote( arguments.record.note );
		bean.setValidityDate( arguments.record.validity_date );
		bean.setExported( arguments.record.exported );
		bean.setActive( arguments.record.active );
		bean.setLang( getLangService().get( arguments.record.lang_id ) );
		bean.setCurrency( getCurrencyService().get( arguments.record.currency_id ) );
		bean.setOwner( getUserService().get( arguments.record.owner_id.toString() ) );
		bean.setPaymentMethod( getPaymentMethodService().get( arguments.record.payment_method_id ) );

		bean.setNessunAgente( arguments.record.nessun_agente );
		if ( !IsNull( arguments.record.agente1 ) && Len( arguments.record.agente1 ) ) bean.setAgente1( arguments.record.agente1.toString() );
		if ( !IsNull( arguments.record.agente2 ) && Len( arguments.record.agente2 ) ) bean.setAgente2( arguments.record.agente2.toString() );
		if ( !IsNull( arguments.record.agente3 ) && Len( arguments.record.agente3 ) ) bean.setAgente3( arguments.record.agente3.toString() );
		if ( !IsNull( arguments.record.agente4 ) && Len( arguments.record.agente4 ) ) bean.setAgente4( arguments.record.agente4.toString() );
		if ( !IsNull( arguments.record.agente5 ) && Len( arguments.record.agente5 ) ) bean.setAgente5( arguments.record.agente5.toString() );
		if ( !IsNull( arguments.record.commission1 ) ) bean.setCommission1( arguments.record.commission1 );
		if ( !IsNull( arguments.record.commission2 ) ) bean.setCommission2( arguments.record.commission2 );
		if ( !IsNull( arguments.record.commission3 ) ) bean.setCommission3( arguments.record.commission3 );
		if ( !IsNull( arguments.record.commission4 ) ) bean.setCommission4( arguments.record.commission4 );
		if ( !IsNull( arguments.record.commission5 ) ) bean.setCommission5( arguments.record.commission5 );
		if ( Len( arguments.record.referente_amministrativo ) ) bean.setReferenteAmministrativo( arguments.record.referente_amministrativo );
		if ( Len( arguments.record.referente_spedizione ) ) bean.setReferenteSpedizione( arguments.record.referente_spedizione );
		if ( Len( arguments.record.customer_type ) ) bean.setCustomerType( arguments.record.customer_type );
		if ( Len( arguments.record.industry ) ) bean.setIndustry( arguments.record.industry );
		if ( Len( arguments.record.rif_libero ) ) bean.setRifLibero( arguments.record.rif_libero );
		if ( IsDate( arguments.record.data_evasione ) ) bean.setDataEvasione( arguments.record.data_evasione );
		if ( !IsNull( arguments.record.sent_to_client ) ) bean.setSentToClient( arguments.record.sent_to_client );
		if ( !IsNull( arguments.record.data_conferma_ordine ) && IsDate( arguments.record.data_conferma_ordine ) ) bean.setDataConfermaOrdine( arguments.record.data_conferma_ordine );
		if ( Len( arguments.record.codice_sdi ) ) bean.setCodiceSdi( arguments.record.codice_sdi );

		//by a trigger from history
		//bean.setStatus( getStatusService().get( arguments.record.status_id ) );
		bean.setStatusHistory( getQuotationStatusHistoryService().get( arguments.record.quotation_status_history_id ) );

		if ( !IsNull( arguments.record.customer_id ) ) {

			var customer = getCustomerService().get( arguments.record.customer_id );
			bean.setCustomer( customer );

			// cerco l'indirizzo di spedizione tra gli indirizzi del customer
			if ( !IsNull( arguments.record.shipping_profile_id ) ) {
				for( var thisAddress in customer.getShippingProfiles() ) {
					if ( thisAddress.getId() == arguments.record.shipping_profile_id ) {
						bean.setShippingProfile( thisAddress );
						break;
					}
				}
			}

		}

		/*
		var quotationStatusHistories = getQuotationStatusHistoryService().list( quotationId = arguments.record.quotation_id, statusId = arguments.record.status_id );

		if ( quotationStatusHistories.len() > 0 && arguments.record.status_id == 'CCN' ) {
			var statusFiles = getFileService().list( quotationStatusHistoryId = quotationStatusHistories[1].getId() );
			if ( statusFiles.len() > 0 ) {
				bean.setStatusFile( statusFiles[1] )
			}
		}
		*/

		if ( !IsNull( arguments.record.opportunity_id ) ) {
			bean.setOpportunity( getOpportunityService().get( arguments.record.opportunity_id.toString() ) );
		}

		if ( !IsNull( arguments.record.lead_id ) ) {
			bean.setLead( getLeadService().get( arguments.record.lead_id ) );
		}

		if ( !IsNull( arguments.record.vat_code_id ) ) {
			bean.setVatCode( getVatCodeService().get( arguments.record.vat_code_id ) );
		}

		if ( !IsNull( arguments.record.sales_agent_account_id ) ) {
			bean.setSalesAgent( getUserService().get( arguments.record.sales_agent_account_id.toString() ) );
		}

		if ( !IsNull( arguments.record.graphic_technician_account_id ) ) {
			bean.setGraphicTechnician( getUserService().get( arguments.record.graphic_technician_account_id.toString() ) );
		}

		bean.setCalculatedAmount(
			getDao().getQuotationTotal( argumentCollection = { quotationId = bean.getId() } )
		);

		// bean.setPricelist( getPricelistService().get( arguments.record.pricelist_id ) );
		// bean.setBillingProfile( getProfileService().get( arguments.record.billing_profile_id ) );
		// bean.setgraphicTechnician( getAccountService().get( arguments.record.graphic_technician_account_id ) );

		return bean;
	}

}
