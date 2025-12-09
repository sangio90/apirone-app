component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationDAO";
	property name="exportCodeDao" inject="ExportCodeDAO";
	property name="quotationSvc" inject="QuotationService";
	property name="quotationItemSvc" inject="QuotationItemService";
	property name="quotationItemProductSvc" inject="QuotationItemProductService";
	property name="quotationItemProductItemSvc" inject="QuotationItemProductItemService";
	property name="quotationZoneSvc" inject="QuotationZoneService";
	property name="quotationItemPositionSvc" inject="QuotationItemPositionService";
	property name="quotationItemSignageRowSvc" inject="QuotationItemSignageRowService";
	property name="exportCodeService" inject="ExportCodeService";
	property name="exportCodeRawValueService" inject="ExportCodeRawValueService";
	property name="rawValueService" inject="RawValueService";
	property name="attributeService" inject="AttributeService";
	property name="AccountService" inject="AccountService";
	property name="ProfileService" inject="ProfileService";
	property name="LangService" inject="LangService";
	property name="StatusService" inject="StatusService";
	property name="PricelistService" inject="PricelistService";
	property name="PaymentMethodService" inject="PaymentMethodService";
	property name="CurrencyService" inject="CurrencyService";
	property name="CustomerService" inject="CustomerService";
	property name="OpportunityService" inject="OpportunityService";
	property name="LeadService" inject="LeadService";
	property name="productService" inject="ProductService";
	property name="productItemService" inject="ProductItemService";
	property name="componentService" inject="ComponentService";
	property name="CountryService" inject="CountryService";
	property name="vatCodeService" inject="VatCodeService";
	property name="CountryService" inject="CountryService";
	property name="QuotationStatusHistoryService" inject="QuotationStatusHistoryService";
	property name="FileService" inject="FileService";
	
	property name="componentCounter" type="Numeric";
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

	public Number function getLastNumber(){

		var rows = search( orderBy = [ { field = "quotation.createdAt", dir = "desc" } ], limit = 1 );

		if( IsNull( rows.getData() ) OR !Len( rows.getData() ) ) {
			return 99;
		}

		return rows.getData()[1].getQuotationNumber();
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
		getDao().delete( arguments.quotationId );

		transaction {
			try {
				var cm = getCacheManager();

				getDao().delete( arguments.quotationId );

				cm.remove( getCacheScope(), arguments.quotationId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotation" );
				outcome.setMessage( "Cannot delete quotation [#arguments.quotationId#]" );
			}
		}

		return outcome;
	}

	// questa firma no è pulita ma è il miglior adattamento
	// questo metodo andrà usato anche da sistemi esterni e legarsi alla session non è consentito
	public String function create( 
		required com.apirone.core.model.bean.Quotation quotation, 
		required String accountId
	){

		arguments.quotation.setQuotationNumber( getLastNumber() + 1 );
		arguments.quotation.setVersionNumber( 0 );

		//TODO: remove this, get status from last record of history
		//arguments.quotation.setStatus( status );

		transaction {

			var newId = getDao().insert( arguments.quotation );
			
			// add status to history
			var history = super.bean( "QuotationStatusHistory" );
			var status = getStatusService().get( "LAV" );
			
			history.setQuotationId( newId );
			history.setStatus( status );
			history.setAccount( getAccountService().get( arguments.accountId ) );

			getQuotationStatusHistoryService().create( history );

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
			"success" = false,
			"error" = null
		};

		transaction {
			if ( arguments.quotationItems.len() ) {

				var allProductItems = [];
				var index = 1;

				for ( var quotationItem in arguments.quotationItems ) {

					setComponentCounter( 0 )

					var code = "";

					var product = quotationItem.getProduct()
					
					if ( IsNull( product ) || IsNull( product.getCategory() ) ) {
						result.error = 'Prodotto o Categoria Prodotto non trovata.'
						return result;
					}
					
					
					var categoryCode = Trim( product.getCategory().getCode() );
					code &= categoryCode;
					var note = "";

					// Se il prodotto è complesso, devo costruire il codice articolo con Linea, Modello, Finitura
					if ( IsInstanceOf( product, "com.apirone.core.model.bean.ProductComplex" ) ) {

						if ( IsNull( product.getLine() ) ) {
							result.error = "Linea prodotto non trovata."
							return result;
						}
						
						var line     = product.getLine();
						var lineCode = Trim( line.getCode() );

						code &= lineCode;

						if ( IsNull( product.getModel() ) ) {
							result.error = "Modello prodotto non trovato."
							return result;
						}

						var model = product.getModel();
						code &= Trim( model.getCode() );

						if ( IsNull( product.getFinish() ) ) {
							result.error = "Finitura prodotto non trovata."
							return result;
						}


						var finishCode = Trim( product.getFinish().getCode() );
						code &= finishCode;
						
						var description = product.getDescription().left( 35 );

						var arKey = code;
						var varCode  = "";
						var colCode  = "000000";

						var quotationItemProductItems = quotationItemProductItemSvc.list(
							quotationItemId = quotationItem.getId(),
							orderBy         = [ { field = "productItem.id" } ]
						);
						
						var productItems   = [];
						var productItemIds = [];
						var importantAttributes = product.getImportantAttributes();



						// faccio passare tutti i product items e creo una struttura dove definisco quelli importanti (che vanno nel varCode) e quelli non importanti (che vanno solo nel colCode)
						for ( var quotationItemProductItem in quotationItemProductItems ) {
							var productItem = quotationItemProductItem.getProductItem();
							if ( !IsNull( productItem ) ) {
								var attributeValue = productItem.getAttributeValue();
								var attribute      = attributeService.get( attributeId = attributeValue.getAttributeId() );
								
								if ( IsNull( attribute ) ) {
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
										productItems.add( {
											"important"   = true,
											"rawValueId"  = rawValue.getId(),
											"attributeId" = attributeValue.getAttributeId()
										} );
									} else {
										productItems.add( {
											"important"   = false,
											"rawValueId"  = rawValue.getId(),
											"attributeId" = attributeValue.getAttributeId()
										} );
									}
								} else {
									productItems.add( {
										"important"   = false,
										"rawValueId"  = rawValue.getId(),
										"attributeId" = attributeValue.getAttributeId()
									} );
								}
								
								productItemIds.add( productItem.getId() );
							}
							
							note &= attribute.getName() & ": " & rawValue.getName() & "; ";
						}

						var productComponents = getComponents( product.getId(), quotationItem, productItemIds );

						//dump(productComponents);
						//abort;

						varCode &= RepeatString( "0", 10 - Len( varCode ) )

						// per valorizzare il colCode, devo cercare nelle nostre tabelle exportCode 
						// ed exportCodeRawValue se esiste corrispondenza. Cerco prima tutti i codici con exportCode = varCode
						var existingCodes = exportCodeService.list( str = code & varCode );

						if ( existingCodes.len() > 0 ) {
							// se ne esiste almeno uno, per ognuno di questi verifico che tutti i product items 
							// (anche quelli non importanti) siano presenti in exportCodeRawValue,
							// se almeno uno non si trova, passo al successivo. Se non trovo nessun exportCode
							// cosa che verifico controllando che il colCode rimanga vuoto, allora creo un nuovo exportCode 
							// e le relative exportCodeRawValue
							for ( var existingCode in existingCodes ) {
								var exportCodeRawValues = exportCodeRawValueService.list(
									exportCodeId = existingCode.getId()
								);

								var allFound = true;
								
								for ( var item in productItems ) {
									var found = false;
									for ( var exportCodeRawValue in exportCodeRawValues ) {
										if ( exportCodeRawValue.getRawValue().getId() == item.rawValueId ) {
											found = true;
											break;
										}
									}
									if ( !found ) {
										allFound = false;
										break;
									}
								}
								
								if ( allFound ) {
									colCode = existingCode.getCounter()
									break;
								}
							}

							if ( colCode == "000000" ) {
								// visto che ci troviamo nel caso in cui esiste almeno un exportCode con quel varCode, 
								// cerco il massimo counter e ne creo uno nuovo incrementandolo di uno

								var maxCounter = exportCodeService.max( exportCode = code & varCode );
								maxCounter     = NumberFormat( maxCounter + 1, "000000" );
								colCode        = maxCounter;

								/* 
									TODO: create createExportCode
								*/

								createExportCodeAndRawValues(
									code         = code,
									varCode      = varCode,
									counterValue = maxCounter,
									productItems = productItems
								)

								/*
								var exportCode = super.bean( "ExportCode" );
								exportCode.setName( code & varCode );
								exportCode.setCounter( maxCounter );
								
								var exportCodeId = exportCodeService.create( "exportCode" = exportCode );
								exportCode.setId( exportCodeId );

								for ( var item in productItems ) {
									var exportCodeRawValue = super.bean( "ExportCodeRawValue" );
									exportCodeRawValue.setExportCode( exportCode );
									exportCodeRawValue.setRawValue( rawValueService.get( item.rawValueId ) );
									exportCodeRawValue.setAttribute( attributeService.get( item.attributeId ) );
									exportCodeRawValue.setImportant( item.important );
									exportCodeRawValueService.create( exportCodeRawValue );
								}
								*/
							}


						} else {
							// non esiste nessun exportCode con quel varCode, 
							// ne creo uno nuovo con counter = '000001' e le relative exportCodeRawValue

							/* 
								TODO: create createExportCode
							*/

							createExportCodeAndRawValues(
								code         = code,
								varCode      = varCode,
								counterValue = "000001",
								productItems = productItems
							)							

							/*
							var exportCode = super.bean( "ExportCode" );
							exportCode.setName( code & varCode );
							exportCode.setCounter( "000001" );
							
							var exportCodeId = exportCodeService.create( "exportCode" = exportCode );
							exportCode.setId( exportCodeId );
							colCode = "000001"
							
							for ( var item in productItems ) {
								var exportCodeRawValue = super.bean( "ExportCodeRawValue" );
								exportCodeRawValue.setExportCode( exportCode );
								exportCodeRawValue.setRawValue( rawValueService.get( item.rawValueId ) );
								exportCodeRawValue.setAttribute( attributeService.get( item.attributeId ) );
								exportCodeRawValue.setImportant( item.important );
								exportCodeRawValueService.create( exportCodeRawValue );
							}
							*/
						}

						arKey = code & varCode & colCode;

						var dataExport = {
							"AR_CHIAVE" = arKey,
							"ARCODART"  = code & RepeatString( "0", 15 - Len( code ) ),
							"ARDESART"  = description,
							"ARDATCAR"  = Now(),
							"ARUNMIS1"  = "PZ",
							"VARCOD"    = varCode,
							"CLCODICE"  = colCode,
							"CLANNOTA"  = note
						}

						result.success = getDao().exportProduct( dataExport );
					}

					if ( IsInstanceOf( product, "com.apirone.core.model.bean.ProductBase" ) ) {
						var productCode = Trim( product.getCode() );
						
						var dataExport = {
							"AR_CHIAVE" = productCode & RepeatString( "0", 31 - Len( productCode ) ),
							"ARCODART"  = productCode & RepeatString( "0", 15 - Len( productCode ) ),
							"ARDESART"  = product.getName().subString( 0, 35 ) & RepeatString(
								"0",
								35 - Len( product.getName().subString( 0, 35 ) )
							),
							"ARDATCAR" = Now(),
							"ARUNMIS1" = "PZ",
							"VARCOD"   = "0000000000",
							"CLCODICE" = "000000",
							"CLANNOTA" = note
						}

						result.success = getDao().exportProduct( dataExport );

						var existingCodes = exportCodeService.list(
							str = productCode & RepeatString( "0", 25 - Len( productCode ) )
						);

						if ( existingCodes.len() > 0 ) {
							continue;
						}

						var exportCode = super.bean( "ExportCode" );
						exportCode.setName( product.getCode() & RepeatString( "0", 25 - Len( product.getCode() ) ) );
						exportCode.setCounter( "000000" );
						exportCodeService.create( "exportCode" = exportCode );
					
					}

					for ( var productComponent in productComponents ) {
						productComponent.DS_CHIAVE = dataExport.AR_CHIAVE;
						productComponent.DSCODART  = dataExport.ARCODART;
						productComponent.DSCODVAR  = dataExport.VARCOD;
						productComponent.DSCODCOL  = dataExport.CLCODICE;
						result.success = getDao().exportDiba( productComponent );
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
				quotationDataResult = prepareExportData(quotation);
				if (!isNull(quotationDataResult.error)) {
					result.error = quotationDataResult.error;
					return result;
				}
				quotationDataHead = quotationDataResult.data;
			}

			if ( quotationItems.len() > 0 ) {
				var allProductItems = [];
				var index = 1;
				for ( var quotationItem in arguments.quotationItems ) {
					var quotationData = {}
					quotationData.append(quotationDataHead);
					setComponentCounter( 0 )
					var code    = "";
					var product = quotationItem.getProduct()
					if ( IsNull( product ) || IsNull( product.getCategory() ) ) {
						result.error = 'Prodotto o Categoria Prodotto non trovata.'
						return result;
					}
					var categoryCode = Trim( product.getCategory().getCode() );
					code &= categoryCode;
					var nota = "";
					// Se il prodotto è complesso, devo costruire il codice articolo con Linea, Modello, Finitura
					if ( IsInstanceOf( product, "com.apirone.core.model.bean.ProductComplex" ) ) {
						if ( IsNull( product.getLine() ) ) {
							result.error = 'Linea Prodotto non trovata.'
							return result;
						}
						var line     = product.getLine();
						var lineCode = Trim( line.getCode() );

						code &= lineCode;

						if ( IsNull( product.getModel() ) ) {
							result.error = 'Modello Prodotto non trovato.'
							return result;
						}
						var model = product.getModel();
						code &= Trim( model.getCode() );

						if ( IsNull( product.getFinish() ) ) {
							result.error = 'Finitura Prodotto non trovata.'
							return result;
						}
						var finishCode = Trim( product.getFinish().getCode() );
						code &= finishCode;
						description = product.getDescription().len() >= 35 ? product.getDescription().subString( 0, 35 ) : product.getDescription();

						var arKey = code;
						var varCode  = "";
						var colCode  = "000000";

						var quotationItemProductItems = quotationItemProductItemSvc.list(
							quotationItemId = quotationItem.getId(),
							orderBy         = [ { field = "productItem.id" } ]
						);
						var productItems   = [];
						var importantAttributes = product.getImportantAttributes();
						// faccio passare tutti i product items e creo una struttura dove definisco quelli importanti (che vanno nel varCode) e quelli non importanti (che vanno solo nel colCode)
						for ( var quotationItemProductItem in quotationItemProductItems ) {
							var productItem = quotationItemProductItem.getProductItem();
							if ( !IsNull( productItem ) ) {
								var attributeValue = productItem.getAttributeValue();
								var attribute      = attributeService.get( attributeId = attributeValue.getAttributeId() );
								if ( IsNull( attribute ) ) {
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
										productItems.add( {
											"important"   = true,
											"rawValueId"  = rawValue.getId(),
											"attributeId" = attributeValue.getAttributeId()
										} );
									} else {
										productItems.add( {
											"important"   = false,
											"rawValueId"  = rawValue.getId(),
											"attributeId" = attributeValue.getAttributeId()
										} );
									}
								} else {
									productItems.add( {
										"important"   = false,
										"rawValueId"  = rawValue.getId(),
										"attributeId" = attributeValue.getAttributeId()
									} );
								}
							}
							nota &= attribute.getName() & ": " & rawValue.getName() & "; ";
						}

						varCode &= RepeatString( "0", 10 - Len( varCode ) )

						// per valorizzare il colCode, devo cercare nelle nostre tabelle exportCode ed exportCodeRawValue se esiste corrispondenza. Cerco prima tutti i codici con exportCode = varCode
						var existingCodes = exportCodeService.list( str = code & varCode );
						if ( existingCodes.len() > 0 ) {
							// se ne esiste almeno uno, per ognuno di questi verifico che tutti i product items (anche quelli non importanti) siano presenti in exportCodeRawValue,
							// se almeno uno non si trova, passo al successivo. Se non trovo nessun exportCode
							// cosa che verifico controllando che il colCode rimanga vuoto, allora creo un nuovo exportCode e le relative exportCodeRawValue
							for ( var existingCode in existingCodes ) {
								var exportCodeRawValues = exportCodeRawValueService.list(
									exportCodeId = existingCode.getId()
								);
								var allFound = true;
								for ( var item in productItems ) {
									var found = false;
									for ( var exportCodeRawValue in exportCodeRawValues ) {
										if ( exportCodeRawValue.getRawValue().getId() == item.rawValueId ) {
											found = true;
											break;
										}
									}
									if ( !found ) {
										allFound = false;
										break;
									}
								}
								if ( allFound ) {
									colCode = existingCode.getCounter();
									break;
								}
								//se non esiste questo varCode con questa combinazione di colCode, vuol dire che sicuramente non sono stati esportati ancora gli articoli quindi torno errore
								result.error = 'Esporta gli Articoli prima.';
								return result;
							}
						} else {
							//se non esiste nemmeno il varCode negli exported vuol dire che non è sicuramente mai stato fatta la export articoli
							result.error = 'Esporta gli Articoli prima.';
							return result;
						}
						arKey = code & varCode & colCode;

						var data = {
							"AR_CHIAVE" = arKey,
							"ARCODART"  = code & RepeatString( "0", 15 - Len( code ) ),
							"ARDESART"  = description,
							"ARDATCAR"  = Now(),
							"ARUNMIS1"  = "PZ",
							"VARCOD"    = varCode,
							"CLCODICE"  = colCode,
							"CLANNOTA"  = nota
						}

						quotationData['CPROWNUM'] = index;
						quotationData['CPROWORD'] = index * 10;
						quotationData['MMCODART'] = data['ARCODART'];
						quotationData['MMCODVAR'] = data['VARCOD'];
						quotationData['MMCODCOL'] = data['CLCODICE'];
						quotationData['ARUNMIS1'] = 'PZ';
						quotationData['MMQTAMOV'] = quotationItem.getQuantity();
						quotationData['MMVALUNI'] = !isNull(quotationItem.getPrice()) ? quotationItem.getPrice().getAmount() : 0;
						//quotationData['MMSCOAR1'] = quotationItem.getDiscount1(); TODO: add discount
						//quotationData['MMSCOAR2'] = quotationItem.getDiscount2();
						quotationData['MMSCOAR1'] = 0;
						quotationData['MMSCOAR2'] = 0;
						// quotationData['MMEVASIO'] = quotation.getValidityDate();
						quotationData['MMEVASIO'] = null;
						quotationData['MM_STATO'] = 'N';

						allProductItems.append(quotationData);
					}

					if ( IsInstanceOf( product, "com.apirone.core.model.bean.ProductBase" ) ) {
						var data = {
							"AR_CHIAVE" = product.getCode() & RepeatString( "0", 31 - Len( product.getCode() ) ),
							"ARCODART"  = product.getCode() & RepeatString( "0", 15 - Len( product.getCode() ) ),
							"ARDESART"  = product.getName().subString( 0, 35 ) & RepeatString(
								"0",
								35 - Len( product.getName().subString( 0, 35 ) )
							),
							"ARDATCAR" = Now(),
							"ARUNMIS1" = "PZ",
							"VARCOD"   = "0000000000",
							"CLCODICE" = "000000",
							"CLANNOTA" = nota
						}

						quotationData['CPROWNUM'] = index;
						quotationData['CPROWORD'] = index * 10;
						quotationData['MMCODART'] = data['ARCODART'];
						quotationData['MMCODVAR'] = data['VARCOD'];
						quotationData['MMCODCOL'] = data['CLCODICE'];
						quotationData['ARUNMIS1'] = 'PZ';
						quotationData['MMQTAMOV'] = quotationItem.getQuantity();
						quotationData['MMVALUNI'] = !isNull(quotationItem.getPrice()) ? quotationItem.getPrice().getAmount() : 0;
						quotationData['MMSCOAR1'] = quotationItem.getDiscount1();
						quotationData['MMSCOAR2'] = quotationItem.getDiscount2();
						// quotationData['MMEVASIO'] = quotation.getValidityDate();
						quotationData['MMEVASIO'] = null;
						quotationData['MM_STATO'] = 'N';

						allProductItems.append(quotationData);
					}

					getDao().export( quotationData );
					index = index + 1;
				}
			}
		}

		result.success = true;

		return result;
	}

	public function getComponents(
		required String productId,
		required quotationItem,
		Array producItemtIds
	){
		var quantity      = quotationItem.getQuantity() ? quotationItem.getQuantity() : 1;
		var allComponents = [];

		var productSvc   = getProductService();
		var componentSvc = getComponentService();

		var productId      = arguments.productId;
		var productItemIds = arguments.producItemtIds;

		var product = productSvc.get( productId );
		if ( IsInstanceOf( product, "com.apirone.core.model.bean.ProductComplex" ) ) {
			
			var bundleComponents = componentSvc.list(
				lineId                         = product.getLine().getId(),
				modelId                        = product.getModel().getId(),
				includeBaseAttributeComponents = true
			);
			
			for ( var bundleComponent in bundleComponents ) {
				allComponents.add( parseComponent( bundleComponent ) );
			}

			if ( IsInstanceOf( quotationItem, "com.apirone.core.model.bean.QuotationItemSignage" ) ) {
				var signageComponents = componentSvc.list(
					signageConfigItemId            = quotationItem.getSignageConfigItem().getId(),
					includeBaseAttributeComponents = true
				);

				if ( producItemtIds.len() > 0 ) {
					for ( var productItemId in productItemIds ) {
						var signageProductComponents = componentSvc.list(
							signageItemProduct = {
								signageConfigItemId = quotationItem.getSignageConfigItem().getId(),
								productItemId       = productItemId
							},

							includeBaseAttributeComponents = true
						);

						for ( var signageProductComponent in signageProductComponents ) {
							allComponents.add( parseComponent( signageProductComponent ) );
						}
					}
				}

				for ( var signageComponent in signageComponents ) {
					allComponents.add( parseComponent( signageComponent ) );
				}
			}
		}

		var productComponents = componentSvc.list( productId = product.getId(), includeBaseAttributeComponents = true );
		
		for ( var productComponent in productComponents ) {
			allComponents.add( parseComponent( productComponent ) );
		}

		if ( producItemtIds.len() > 0 ) {
			for ( var productItemId in productItemIds ) {
				var productItemComponents = componentSvc.list(
					productItemId                  = productItemId,
					includeBaseAttributeComponents = true
				);
				for ( var productItemComponent in productItemComponents ) {
					allComponents.add( parseComponent( productItemComponent ) );
				}
			}
		}

		return allComponents;
	}

	public function parseComponent( com.apirone.core.model.bean.Component component ){
		var counter = getComponentCounter();
		
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
			"CPROWNUM" = counter + 1,
			"CPROWORD" = ( counter + 1 ) * 10,
			"DSTIPRIG" = "R"
		};

		setComponentCounter( counter + 1 );

		return componente;
	}

	private function prepareExportData( required com.apirone.core.model.bean.Quotation quotation ){
		var result = {
			"data" = {},
			"error" = null
		};
		
		var customer = quotation.getCustomer();

		if (isNull(quotation.getShippingProfile())) {
			result.error = "Dati spedizione non trovati."
			return result;
		}

		var quotationData = {
			"MMSERIAL" = quotation.getSerial(),
			"MMNUMDOC" = quotation.getQuotationNumber() & "/" & quotation.getVersionNumber(),
			"MMDATDOC" = quotation.getCreatedAt(),
			// "MMDATEVA" = quotation.getValidityDate(),
			"MMDATEVA" = null,
			"MMRIFORD" = !IsNull( quotation.getOpportunity() ) ? quotation.getOpportunity().getName() : "",
			"MMNUMLIS" = 1,
			"MMCODAGE" = (!isNull(quotation.getSalesAgentAccount())) ? quotation.getSalesAgentAccount().getEmail() : null, //trovata tabella AZAPI_AGENTI campo id AGECOD, campo mail AGEMAI
			"MMCODPAG" = quotation.getPaymentMethod().getId(),
			"MMCODVAL" = quotation.getCurrency().getId(),
			"CF_IDCLI" = customer.getId(),
			"CFDESCR1" = customer.getCompany(),
			"CFINDIRI" = customer.getStreet(),
			"CFLOCALI" = customer.getCity(),
			"CFPROVIN" = customer.getState(),
			"CFSTAISO" = customer.getCountry()?.getIsoCode(),
			"CFPARIVA" = customer.getVatNumber(),
			"CFTELEFO" = customer.getPhone(),
			"CFBLOCCO" = "N",
			"CFMOROSO" = "N",
			"DEDESDOD" = customer.getCompany(),
			"DEINDDOD" = customer.getStreet(),
			"DELOCDOD" = customer.getCity(),
			"DEPRODOD" = customer.getState(),
			"DENAZDOD" = customer.getCountry()?.getIsoCode(),
			"DEIDDMER" = quotation.getShippingProfile().getId(),
			"DEDESMER" = quotation.getShippingProfile().getCompany(),
			"DEINDMER" = quotation.getShippingProfile().getStreet(),
			"DELOCMER" = quotation.getShippingProfile().getCity(),
			"DEPROMER" = quotation.getShippingProfile().getState(),
			"DENAZMER" = quotation.getShippingProfile().getCountry()?.getIsoCode()
		};


		result.data = quotationData;
		return result;
	}

	public String function clone( required com.apirone.core.model.bean.Quotation quotation, required String status ){
		var originalQuotation = arguments.quotation;
		var clonedQuotation   = Duplicate( originalQuotation );
		originalQuotation.setActive( 0 );
		quotationSvc.update( originalQuotation );
		clonedQuotation.setId( LCase( CreateUUID() ) );
		clonedQuotation.setVersionNumber( originalQuotation.getVersionNumber() + 1 );
		clonedQuotation.setActive( 1 );
		var status = StatusService.get( status );
		clonedQuotation.setStatus( status );

		var newQuotationId = getDao().insert( clonedQuotation );

		var quotationZoneIdsMap         = {};
		var quotationZones              = quotationZoneSvc.list( quotationId = originalQuotation.getId() );
		var quotationZonesWithoutParent = ArrayFilter( quotationZones, function( quotationZone ){
			return IsNull( quotationZone.getOrigin() );
		} )
		for ( var quotationZone in quotationZonesWithoutParent ) {
			var clonedZone = Duplicate( quotationZone );
			clonedZone.setQuotation( quotationSvc.get( newQuotationId ) );
			clonedZone.setId( LCase( CreateUUID() ) );
			var newQuotationZoneId                       = quotationZoneSvc.create( clonedZone );
			quotationZoneIdsMap[ quotationZone.getId() ] = newQuotationZoneId;
		}

		var quotationZonesWithParent = ArrayFilter( quotationZones, function( quotationZone ){
			return !IsNull( quotationZone.getOrigin() );
		} )
		for ( var quotationZone in quotationZonesWithParent ) {
			var clonedZone = Duplicate( quotationZone );
			clonedZone.setQuotation( quotationSvc.get( newQuotationId ) );
			clonedZone.setId( LCase( CreateUUID() ) );
			var newOriginId = quotationZoneIdsMap[ quotationZone.getOrigin().getId() ];
			clonedZone.setOrigin( quotationZoneSvc.get( newOriginId ) );
			var newQuotationZoneId                       = quotationZoneSvc.create( clonedZone );
			quotationZoneIdsMap[ quotationZone.getId() ] = newQuotationZoneId;
		}

		var quotationItems = quotationItemSvc.list( quotationId = originalQuotation.getId() );
		for ( var quotationItem in quotationItems ) {
			var clonedItem = Duplicate( quotationItem );
			clonedItem.setQuotation( quotationSvc.get( newQuotationId ) );
			clonedItem.setQuotationZone(
				quotationZoneSvc.get( quotationZoneIdsMap[ quotationItem.getQuotationZone().getId() ] )
			);
			clonedItem.setId( LCase( CreateUUID() ) );
			var newQuotationItemId = quotationItemSvc.create( clonedItem );

			var quotationItemSignageRows = quotationItemSignageRowSvc.list( quotationItemId = quotationItem.getId() );
			for ( quotationItemSignageRow in quotationItemSignageRows ) {
				var clonedQuotationItemSignageRow = Duplicate( quotationItemSignageRow );
				clonedQuotationItemSignageRow.setQuotationItemId( newQuotationItemId );
				quotationItemSignageRowSvc.create( clonedQuotationItemSignageRow );
			}

			var quotationItemPositions = quotationItemPositionSvc.list( quotationItemId = quotationItem.getId() );
			for ( quotationItemPosition in quotationItemPositions ) {
				var clonedQuotationItemPosition = Duplicate( quotationItemPosition );
				clonedQuotationItemPosition.setQuotationItem( clonedItem );
				clonedQuotationItemPosition.setQuotationZone(
					quotationZoneSvc.get( quotationZoneIdsMap[ quotationItem.getQuotationZone().getId() ] )
				);
				quotationItemPositionSvc.create( clonedQuotationItemPosition );
			}
		}

		return newQuotationId;
		super.getCacheManager().remove( getCacheScope(), arguments.quotation.getId() );

		return arguments.quotation;
	}


	/*
		private method
	*/

	/**
	 * Crea un oggetto ExportCode e i relativi ExportCodeRawValue.
	 * * @param code Il codice base per il nome.
	 * @param varCode La variabile del codice da concatenare.
	 * @param productItems Array di oggetti item con rawValueId, attributeId e important.
	 * @param counterValue Il valore del contatore. Di default è '000001', ma può essere maxCounter.
	 */
	public void function createExportCodeAndRawValues(
		required string code, 
		required string varCode, 
		required array productItems, 
		String counterValue = "000001"
	) {
		// Definizione delle variabili di servizio (assumendo che siano iniettate o disponibili)
		// Queste dovrebbero essere accessibili nello scope della funzione o del CFC
		var exportCodeService = variables.exportCodeService;
		var rawValueService = variables.rawValueService;
		var attributeService = variables.attributeService;
		var exportCodeRawValueService = variables.exportCodeRawValueService;

		// 1. Impostazione e creazione di ExportCode
		var exportCode = super.bean( "ExportCode" );
		
		exportCode.setName( arguments.code & arguments.varCode );
		exportCode.setCounter( arguments.counterValue );

		var exportCodeId = exportCodeService.create( exportCode = exportCode );
		exportCode.setId( exportCodeId );

		// 2. Creazione di ExportCodeRawValue per ogni item
		for ( var item in arguments.productItems ) {
			var exportCodeRawValue = super.bean( "ExportCodeRawValue" );
			
			exportCodeRawValue.setExportCode( exportCode );
			exportCodeRawValue.setRawValue( rawValueService.get( item.rawValueId ) );
			exportCodeRawValue.setAttribute( attributeService.get( item.attributeId ) );
			exportCodeRawValue.setImportant( item.important );
			
			exportCodeRawValueService.create( exportCodeRawValue );
		}
	}
	
	private com.apirone.core.model.bean.Quotation function build( required String quotationId ){
		var record = getDao().read( arguments.quotationId );

		if ( record.recordCount ) {
			var bean = super.bean( "Quotation" );

			var calculatedAmount = 0;

			bean.setId( record.quotation_id );
			bean.setSerial( record.serial );
			bean.setName( record.quotation );
			bean.setQuotationNumber( record.quotation_number );
			bean.setVersionNumber( record.version_number );
			bean.setQuotationDate( record.quotation_date );
			bean.setCreatedAt( record.created_at );
			bean.setNotes( record.notes );
			bean.setValidityDate( record.validity_date );
			bean.setExported( record.exported );
			bean.setActive( record.active );
			bean.setLang( getLangService().get( record.lang_id ) );
			bean.setCurrency( getCurrencyService().get( record.currency_id ) );
			bean.setOwner( getAccountService().get( record.owner_id ) );
			bean.setPaymentMethod( getPaymentMethodService().get( record.payment_method_id ) );

			//by a trigger from history
			bean.setStatus( getStatusService().get( record.status_id ) ); 

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
				bean.setOpportunity( getOpportunityService().get( record.opportunity_id ) );
			}

			if ( !IsNull( record.lead_id ) ) {
				bean.setLead( getLeadService().get( record.lead_id ) );
			}

			if ( !IsNull( record.vat_code_id ) ) {
				bean.setVatCode( getVatCodeService().get( record.vat_code_id ) );
			}

			if (!isNull(record.sales_agent_account_id)) {
				bean.setSalesAgentAccount( getAccountService().get( record.sales_agent_account_id ) );
			}

			bean.setCalculatedAmount(
				getDao().getQuotationTotal( argumentCollection = { quotationId = bean.getId() } )
			);

			// bean.setPricelist( getPricelistService().get( record.pricelist_id ) );
			// bean.setBillingProfile( getProfileService().get( record.billing_profile_id ) );
			// bean.setShippingProfile( getProfileService().get( record.shipping_profile_id ) );
			// bean.setGraphicTechnicianAccount( getAccountService().get( record.graphic_technician_account_id ) );

			return bean;
		}

		return NullValue();
	}

}
