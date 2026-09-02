component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var memy   = super.getMementify();

		param rc.id = "";
		param rc.categoryId = "";
		param rc.quotationZoneId = "";

		prc.jsFiles.add( "app-file" );

		params[ "typeId" ] = getTypeIdBySlug( rc.typeId );
		params[ "quotationId" ] = rc.id;
		params[ "orderBy" ] = [ { "field" = "quotationItem.ordinamento", "dir" = "asc" }, { "field" = "quotationZonePosition.code", "dir" = "asc" } ];
		params[ "quotationZoneId" ] = Len( rc.quotationZoneId ) ? rc.quotationZoneId : null;

		var rows = super.fire( "QuotationItem.search", params );
		var data = ( memy.convertList( rows.getData() ) );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );
		

		event.setValue( "result", result );
	}

	function listByZone( event, rc, prc ){
		
		var result = super.getResult();
		var params = super.paramsFromUrl();

		params[ "quotationId" ] = rc.id;
		params[ "quotationZoneId" ] = Len( rc.zoneId ) ? rc.zoneId : null;

		var rows = super.fire( "QuotationItem.search", params );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( rows.getData() );

		event.setValue( "result", result );
	}

	function editArticle( event, rc, prc ){
		var data   = {}
		var result = super.getResult();
		//var params = super.paramsFromUrl();
		var memy     = super.getMementify();

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var parsedQuotationItemData = memy.convert( quotationItem, "editArticle" );

		data.append( { "quotationItem" = parsedQuotationItemData } );

		result.setData( data );
		event.setValue( "result", result );
	}

	function saveArticle( event, rc, prc ){
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";

		var result = super.getResult();

		var id   = json.quotationItem.id;

		if ( !Len( id ) ) {
			var bean = super.bean( "QuotationItem" );
		} else {
			var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
		}

		bean.setQuotation( super.service( "Quotation" ).get( json.id ) );
		var quotationZone = super.service( "QuotationZone" ).list( quotationId = json.id, name = 'Non assegnato' );
		bean.setQuotationZone( quotationZone[ 1 ] );
		bean.setQuantity( json.quotationItem.quantity );
		bean.setArticle( super.fire( "Article.get", { articleId = json.quotationItem.article.id } ) );

		var price = super.bean( "QuotationItemPrice" );
		
		price.setDiscount1( 0 );
		price.setDiscount2( 0 );
		var method  = super.bean( "PriceMethod" );
		price.setMethod( method.setId( "F" ) );
		price.setAmount( Val( json.quotationItem.price.amount ) ? json.quotationItem.price.amount : 0 );
		var status  = super.bean( "Status" );
		bean.setStatus( status.setId( json.quotationItem.status.id ) );
		bean.setNote( json.quotationItem.note );

		bean.setPrice( price );

		if ( !Len( id ) ) {
			messageId = "quotationItem.created";
			thisId    = super.fire( "quotationItem.create", [ bean ] )
		} else {
			messageId = "quotationItem.updated";
			thisId    = super.fire( "quotationItem.update", [ bean ] );
			if ( !IsNull( bean.getInstanceGroupId() ) && Len( bean.getInstanceGroupId() ) ) {
				super.fire( "QuotationItem.syncInstanceGroup", { quotationItemId = thisId } );
			}
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message, "id" = thisId } );

		event.setValue( "result", result );
	}


	function listFruits( event, rc, prc ){
		
		var data   = [];
		var result = super.getResult();
		var memy   = super.getMementify();

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );
		var fruits = quotationItem.getFruits();

		fruits.each( function( fruit ){
			data.add( memy.convert( fruit, "editForPlace" ) );
		} );

		result.setData( data );
		event.setValue( "result", result );
	}	

	function editPlate( event, rc, prc ){
		
		var data   = {};
		var result = super.getResult();
		var memy   = super.getMementify();

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var parsedQuotationItemData = memy.convert( quotationItem, "editPlate" );

		data.append( {
			"quotationItem" = parsedQuotationItemData,
			"plate" = {}
		} );

		result.setData( data );
		event.setValue( "result", result );
	}

	function plateExport( event, rc, prc ){
		var result = super.getResult();
		var langId = "IT";

		var item = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var data = {
			"id"       = item.getId(),
			"quantita" = item.getQuantity(),
			"note"     = item.getNote(),
			"speciale" = item.getSpecial()
		};

		if ( !isNull( item.getQuotationZone() ) ) {
			data["zona"] = item.getQuotationZone().getName();
		}

		if ( !isNull( item.getPosition() ) ) {
			data["posizione"] = item.getPosition().getCode();
		}

		var product = item.getProduct();
		var attributiPlacca = [];
		for ( var qi in item.getItems() ) {
			var pi = qi.getProductItem();
			ArrayAppend( attributiPlacca, {
				"attributo" = pi.getAttribute().getName( langId ),
				"valore"    = pi.getAttributeValue().getName( langId ),
				"nota"      = qi.getNote()
			});
		}
		data["prodotto"] = {
			"id"       = product.getId(),
			"codice"   = product.getCode(),
			"linea"    = product.getLine().getName( langId ),
			"modello"  = product.getModel().getCode() & " – " & product.getModel().getName( langId ),
			"finitura" = product.getFinish().getCode() & " – " & product.getFinish().getName( langId ),
			"attributi" = attributiPlacca
		};

		if ( !isNull( item.getFrame() ) ) {
			data["frame"] = {
				"codice"       = item.getFrame().getCode(),
				"orientamento" = item.getFrame().getOrientation().getId()
			};
		}

		var frutti = [];
		var fruitOrder = 1;
		for ( var fruit in item.getFruits() ) {
			var fruttoProdotto = fruit.getFruit();
			var slots = [];
			for ( var pos in fruit.getPositions() ) {
				ArrayAppend( slots, { "slot" = pos.position, "ordine" = pos.order } );
			}
			var attributiFrutto = [];
			for ( var qif in fruit.getItems() ) {
				var pif = qif.getProductItem();
				ArrayAppend( attributiFrutto, {
					"attributo" = pif.getAttribute().getName( langId ),
					"valore"    = pif.getAttributeValue().getName( langId ),
					"nota"      = qif.getNote()
				});
			}
			ArrayAppend( frutti, {
				"ordine"  = fruitOrder,
				"note"    = fruit.getNote(),
				"prodotto" = {
					"id"       = fruttoProdotto.getId(),
					"codice"   = fruttoProdotto.getCode(),
					"nome"     = fruttoProdotto.getName( langId ),
					"linea"    = fruttoProdotto.getLine().getName( langId ),
					"modello"  = fruttoProdotto.getModel().getCode() & " – " & fruttoProdotto.getModel().getName( langId ),
					"finitura" = fruttoProdotto.getFinish().getCode() & " – " & fruttoProdotto.getFinish().getName( langId )
				},
				"slots"     = slots,
				"attributi" = attributiFrutto
			});
			fruitOrder++;
		}
		data["frutti"] = frutti;

		if ( !isNull( item.getPrice() ) ) {
			var price = item.getPrice();
			var righe = [];
			for ( var line in price.getLines() ) {
				ArrayAppend( righe, {
					"nome"    = line.getName(),
					"importo" = line.getAmount(),
					"costo"   = line.getCost()
				});
			}
			data["prezzo"] = {
				"totale"       = price.getTotal(),
				"costo_totale" = price.getCost(),
				"sconto1"      = !isNull( price.getDiscount1() ) ? price.getDiscount1() : 0,
				"sconto2"      = !isNull( price.getDiscount2() ) ? price.getDiscount2() : 0,
				"metodo"       = price.getMethod().getId(),
				"righe"        = righe
			};
		}

		result.setData( data );
		event.setValue( "result", result );
	}

	function plate3dExport( event, rc, prc ){
		var result = super.getResult();
		var item = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );
		result.setData( build3dItemJson( item ) );
		event.setValue( "result", result );
	}

	function plates3dExport( event, rc, prc ){
		var result = super.getResult();
		var plates = super.service( "QuotationItem" ).list( quotationId = rc.id, typeId = "PLA" );
		var data = [];
		for ( var plate in plates ) {
			var fullItem = super.fire( "QuotationItem.get", { quotationItemId = plate.getId() } );
			ArrayAppend( data, build3dItemJson( fullItem ) );
		}
		result.setData( data );
		event.setValue( "result", result );
	}

	private Struct function build3dItemJson( required item, String langId = "IT" ){
		var codiceArticolo = "";
		var codiceVariante = "";
		var codiceColore   = "";

		if ( !isNull( arguments.item.getHash() ) && Len( Trim( arguments.item.getHash() ) ) ) {
			var productHash = super.service( "ProductHash" ).getByHash( arguments.item.getHash() );
			if ( !isNull( productHash ) ) {
				var exportCodes = super.service( "ExportCode" ).list( productHashId = productHash.getId() );
				if ( exportCodes.len() > 0 ) {
					codiceArticolo = exportCodes[1].getName().left( 15 );
					codiceVariante = exportCodes[1].getName().right( 10 );
					codiceColore   = exportCodes[1].getCounter();
				}
			}
		}

		var quantita = arguments.item.getQuantity();
		if ( !isNull( arguments.item.getQuotationZone() ) ) {
			if ( !isNull( arguments.item.getQuotationZone().getOrigin() ) ) {
				quantita *= arguments.item.getQuotationZone().getOrigin().getQuantity();
			}
			quantita *= arguments.item.getQuotationZone().getQuantity();
		}

		var product = arguments.item.getProduct();
		var attributiPlacca = [];
		for ( var qi in arguments.item.getItems() ) {
			var pi = qi.getProductItem();
			ArrayAppend( attributiPlacca, {
				"attributo"      = pi.getAttribute().getName( arguments.langId ),
				"attributo_code" = pi.getAttribute().getCode(),
				"valore"         = pi.getAttributeValue().getName( arguments.langId ),
				"valore_code"    = !isNull( pi.getAttributeValue().getRawValue() ) ? pi.getAttributeValue().getRawValue().getCode() : ""
			});
		}

		var placca = {
			"modello"   = !isNull( product.getModel() )  ? product.getModel().getCode()  & " – " & product.getModel().getName( arguments.langId )  : "",
			"finitura"  = !isNull( product.getFinish() ) ? product.getFinish().getCode() & " – " & product.getFinish().getName( arguments.langId ) : "",
			"attributi" = attributiPlacca
		};

		var placcaOrientationId = "";

		// mappa slot (intero, 1..N) -> orientamento effettivo del blocco che lo contiene,
		// stesso algoritmo di FrameAjaxController.buildBlocksResponse()
		var slotOrientations = {};

		if ( !isNull( arguments.item.getFrame() ) ) {
			placcaOrientationId    = arguments.item.getFrame().getOrientation().getId();
			placca["orientamento"] = placcaOrientationId;

			// arguments.item.getFrame() è un bean "snapshot" con la sola orientation
			// valorizzata (vedi QuotationItemService.buildFromRow/getMany): per i blocchi
			// serve ricaricare il Frame vero e proprio dal suo code (== code del modello).
			if ( !isNull( product.getModel() ) && Len( product.getModel().getCode() ) ) {
				var frameBean = super.service( "Frame" ).getByCode( product.getModel().getCode() );

				if ( !isNull( frameBean ) ) {
					placca["frame"] = frameBean.getCode();

					if ( !isNull( frameBean.getBlocks() ) && ArrayLen( frameBean.getBlocks() ) ) {
						var blockOverrides = {};
						if ( !isNull( arguments.item.getBlockOrientations() ) && IsJSON( arguments.item.getBlockOrientations() ) ) {
							blockOverrides = DeserializeJSON( arguments.item.getBlockOrientations() );
						}

						var slotCounter = 0;
						for ( var block in frameBean.getBlocks() ) {
							var effectiveOri = ( block.getOrientationMode() == "HAV" ? placcaOrientationId : block.getOrientationMode() );

							var orderKey = ToString( block.getOrder() );
							if ( StructKeyExists( blockOverrides, orderKey ) && ListFindNoCase( "HOR,VER", blockOverrides[ orderKey ] ) ) {
								effectiveOri = UCase( blockOverrides[ orderKey ] );
							}

							for ( var i = 1; i <= block.getSlotCount(); i++ ) {
								slotCounter++;
								slotOrientations[ slotCounter ] = effectiveOri;
							}
						}
					}
				}
			}
		}

		var frutti = [];
		var fruitOrder = 1;
		for ( var fruit in arguments.item.getFruits() ) {
			var fruttoProdotto = fruit.getFruit();
			if ( isNull( fruttoProdotto ) ) {
				fruitOrder++;
				continue;
			}
			var slots = [];
			if ( !isNull( fruit.getPositions() ) ) {
				for ( var pos in fruit.getPositions() ) {
					ArrayAppend( slots, pos.position );
				}
			}

			// orientamento del frutto = orientamento del blocco a cui appartiene il suo primo slot;
			// se il blocco non è individuabile (placca legacy, slot non numerico) si usa quello della placca
			var orientamentoFrutto = placcaOrientationId;
			if ( slots.len() && IsNumeric( slots[1] ) && StructKeyExists( slotOrientations, slots[1] ) ) {
				orientamentoFrutto = slotOrientations[ slots[1] ];
			}

			var attributiFrutto = [];
			if ( !isNull( fruit.getItems() ) ) {
				for ( var qif in fruit.getItems() ) {
					var pif = qif.getProductItem();
					ArrayAppend( attributiFrutto, {
						"attributo"      = pif.getAttribute().getName( arguments.langId ),
						"attributo_code" = pif.getAttribute().getCode(),
						"valore"         = pif.getAttributeValue().getName( arguments.langId ),
						"valore_code"    = !isNull( pif.getAttributeValue().getRawValue() ) ? pif.getAttributeValue().getRawValue().getCode() : ""
					});
				}
			}
			ArrayAppend( frutti, {
				"ordine"       = fruitOrder,
				"codice"       = fruttoProdotto.getCode(),
				"modello"      = !isNull( fruttoProdotto.getModel() )  ? fruttoProdotto.getModel().getCode()  & " – " & fruttoProdotto.getModel().getName( arguments.langId )  : "",
				"finitura"     = !isNull( fruttoProdotto.getFinish() ) ? fruttoProdotto.getFinish().getCode() & " – " & fruttoProdotto.getFinish().getName( arguments.langId ) : "",
				"slots"        = slots,
				"orientamento" = orientamentoFrutto,
				"attributi"    = attributiFrutto
			});
			fruitOrder++;
		}

		return {
			"codice_articolo" = codiceArticolo,
			"codice_variante" = codiceVariante,
			"codice_colore"   = codiceColore,
			"quantita"        = quantita,
			"placca"          = placca,
			"frutti"          = frutti
		};
	}

	function signageExport( event, rc, prc ){
		var result = super.getResult();
		var langId = "IT";

		var item = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var data = {
			"id"       = item.getId(),
			"quantita" = item.getQuantity(),
			"note"     = item.getNote(),
			"speciale" = item.getSpecial()
		};

		if ( !isNull( item.getQuotationZone() ) ) {
			data["zona"] = item.getQuotationZone().getName();
		}

		if ( !isNull( item.getPosition() ) ) {
			data["posizione"] = item.getPosition().getCode();
		}

		var product = item.getProduct();
		var attributiSegnaletica = [];
		if ( !isNull( item.getItems() ) ) {
			for ( var qi in item.getItems() ) {
				var pi = qi.getProductItem();
				ArrayAppend( attributiSegnaletica, {
					"attributo" = pi.getAttribute().getName( langId ),
					"valore"    = pi.getAttributeValue().getName( langId ),
					"nota"      = qi.getNote()
				});
			}
		}
		data["prodotto"] = {
			"id"        = product.getId(),
			"codice"    = product.getCode(),
			"linea"     = product.getLine().getName( langId ),
			"modello"   = product.getModel().getCode() & " – " & product.getModel().getName( langId ),
			"finitura"  = product.getFinish().getCode() & " – " & product.getFinish().getName( langId ),
			"attributi" = attributiSegnaletica
		};

		var configItem = item.getSignageConfigItem();
		var signageConfig = super.fire( "SignageConfig.get", { signageConfigId = configItem.getSignageConfigId() } );
		data["segnaletica"] = {
			"font"         = signageConfig.getFont().getName( langId ),
			"altezza_font" = configItem.getHeightInPixel(),
			"righe_max"    = configItem.getRowCount(),
			"char_max"     = configItem.getCharCount()
		};

		var righe = [];
		for ( var row in item.getSignageRows() ) {
			ArrayAppend( righe, {
				"ordine"       = row.getOrderby(),
				"allineamento" = row.getTextAlign(),
				"contenuto"    = row.getContent(),
				"char_count"   = row.getCharCount()
			});
		}
		data["righe"] = righe;

		if ( !isNull( item.getPrice() ) ) {
			var price = item.getPrice();
			var righePrezzo = [];
			for ( var line in price.getLines() ) {
				ArrayAppend( righePrezzo, {
					"nome"    = line.getName(),
					"importo" = line.getAmount(),
					"costo"   = line.getCost()
				});
			}
			data["prezzo"] = {
				"totale"       = price.getTotal(),
				"costo_totale" = price.getCost(),
				"sconto1"      = !isNull( price.getDiscount1() ) ? price.getDiscount1() : 0,
				"sconto2"      = !isNull( price.getDiscount2() ) ? price.getDiscount2() : 0,
				"metodo"       = price.getMethod().getId(),
				"righe"        = righePrezzo
			};
		}

		result.setData( data );
		event.setValue( "result", result );
	}

	function editSignage( event, rc, prc ){
		
		var data   = {};
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mm     = super.getMementify();

		params[ "quotationItemId" ] = rc.id;

		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );
		var parsedQuotationItemData = mm.convert( quotationItem, "edit" );

		var signageConfig = super.fire(
			"SignageConfig.get",
			{
				signageConfigId = quotationItem.getSignageConfigItem().getSignageConfigId()
			}
		);
		var parsedSignageConfigData = ( mm.convert( signageConfig ) );

		data.append( {
			"quotationItem" = parsedQuotationItemData,
			"signageConfig" = parsedSignageConfigData
		} );

		result.setData( data );
		event.setValue( "result", result );
	}

	function editAccessory( event, rc, prc ){
		var data   = {}
		var result = super.getResult();
		var memy     = super.getMementify();
		var quotationItem = super.fire( "QuotationItem.get", { quotationItemId = rc.id } );

		var item = memy.convert( quotationItem, "edit" );
		item.product["category"] = memy.convert( quotationItem.getProduct().getCategory() );
		data.append( { "quotationItem" = item } );

		result.setData( data );
		event.setValue( "result", result );
	}

	function saveAccessory( event, rc, prc ){
		setting requestTimeout=120;
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var status = super.bean( "Status" );
		var result = super.getResult();

		var id   = json.quotationItem.id;
		var type = json.type

		if ( !Len( id ) ) {
			var bean = super.bean( "QuotationItem" );
		} else {
			var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
		}

		bean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) ); //TODO: move to QuotationId
		bean.setQuotationZone( super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id ) );
		bean.setQuantity( json.quotationItem.quantity );
		bean.setCustomImage( json.quotationItem.customImage );

		bean.setSpecial( json.quotationItem.special );
		bean.setNote( json.quotationItem.note );
		bean.setStatus( status.setId( json.quotationItem.status.id ) );
		if ( !Len( id ) ) {
			json.quotationItem.id = lcase(createUUID());
		}

		if( Len( json.quotationItem?.position?.code ) ) {
			var position = populatePositionBean( json.quotationItem.position );
			bean.setPosition( position );
		} else  {
			bean.setPosition( null );
		}
		
		var price = super.fire( 'QuotationItem.getPricing', { 'data' = json } );
		bean.setPrice( price );

		var product = super
			.fire(
				"Product.search",
				{
					lineId     = json.quotationItem.product.line.id,
					modelId    = json.quotationItem.product.model.id,
					categoryId = json.quotationItem.product.category.id,
					finishId   = json.quotationItem.product.finish.id
				}
			)
			.getData();

		if ( !Len( product ) || Len( product ) > 1 ) {
			var message = "Combinazione Linea/Modello/Categoria/Finitura non disponibile.";
			result.setData( { "error" = message } );
			result.setStatus( "ERRORE" );
			event.setValue( "result", result );
			return;
		}

		product = product[ 1 ];
		
		bean.setProduct( super.fire( "Product.get", { "productId" = product.getId() } ) );
		
		transaction {
			if ( !Len( id ) ) {
				messageId = "quotationItem.created";
				thisId    = super.fire( "quotationItem.create", [ bean ] )
			} else {
				messageId = "quotationItem.updated";
				thisId    = super.fire( "quotationItem.update", [ bean ] );
				if ( !IsNull( bean.getInstanceGroupId() ) && Len( bean.getInstanceGroupId() ) ) {
					super.fire( "QuotationItem.syncInstanceGroup", { quotationItemId = thisId } );
				}
			}

			var quotationItemProductItems = super.fire(
				"quotationItemProductItem.list",
				{ quotationItemId = thisId }
			);

			quotationItemProductItems.each( function( quotationItemProductItem ){
				super.fire(
					"quotationItemProductItem.delete",
					{ "productItemId" = quotationItemProductItem.getId() }
				)
			} );

			if ( json.quotationItem.product.keyExists( "items" ) ) {
				var _items1 = json.quotationItem.product.items ?: [];
				var productItemsData = isArray( _items1 ) ? _items1 : ( structKeyExists( _items1, "_data" ) ? _items1._data : [] );
				productItemsData.each( function( productItemRow ){
					var selectedValue = selectedValues = ArrayFilter( productItemRow.values, function( v ){
						return v.selected;
					} );

					if ( Len( selectedValue ) > 0 ) {
						selectedValue   = selectedValue[ 1 ];
						var productItem = super.fire(
							"productItem.get",
							{ "productItemId" = selectedValue.product_item_id }
						);

						var quotationItemProductItemBean = super.bean( "quotationItemProductItem" );
						
						quotationItemProductItemBean.setQuotationItemId( thisId );
						quotationItemProductItemBean.setProductItem( productItem );
						quotationItemProductItemBean.setOrigin( productItem.getOrigin() );
						quotationItemProductItemBean.setLevel( productItemRow.level );
						if (structKeyExists(productItemRow, 'note')) {
							quotationItemProductItemBean.setNote( productItemRow.note );
						}
						quotationItemProductItemBean.setId( thisId )

						super.fire(
							"quotationItemProductItem.create",
							{ "productItem" = quotationItemProductItemBean }
						)
					}
				} )
			}

			super.fire( "quotationItem.aggiornaPrezzoAltriArticoliByQuotationIdAndProductId", {
				"quotationId" = json.quotationId,
				"quotationItemId" = thisId,
				"productId" = json.quotationItem.product.id
				}
			);
		}

		saveImage( imageBase64 = json.imageBase64, quotationItemId = thisId, typeId = "accessory" );

		if ( !Len( id ) ) {
			var productHash = super.fire('ProductHash.createHash', { quotationItemId = thisId });
			super.fire('quotationItem.updateHash', { quotationItemId = thisId, hash = productHash });
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message, "id" = thisId } );

		event.setValue( "result", result );
	}

	function saveSignage( event, rc, prc ){
		setting requestTimeout=120;
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var status = super.bean( "Status" );
		var result = super.getResult();

		var id   = json.quotationItem.id;
		var type = json.type

		if ( !Len( id ) ) {
			var bean = super.bean( "QuotationItemSignage" );
		} else {
			var bean = super.fire( "QuotationItem.get", { quotationItemId = id } );
		}

		bean.setSpecial( json.quotationItem.special );
		bean.setNote( json.quotationItem.note );
		bean.setStatus( status.setId( json.quotationItem.status.id ) );
		if ( !Len( id ) ) {
			json.quotationItem.id = lcase(createUUID());
		}
		try {
			var price = super.fire( 'QuotationItem.getSignagePricing', { 'data' = json } );
		} catch ( "ApirOne.NoPriceConfigured" e ) {
			result.setStatus( "INVALID" );
			result.setData( { "general" = [ { "message" = e.message } ] } );
			event.setValue( "result", result );
			return;
		}
		bean.setPrice( price );

		if( Len( json.quotationItem?.position?.code ) ) {
			var position = populatePositionBean( json.quotationItem.position );
			bean.setPosition( position );
		} else  {
			bean.setPosition( null );
		}

		bean.setSignageConfigItem(
			super.service( "SignageConfigItem" ).get( json.quotationItem.signageConfigItem.id )
		);

		bean.setQuotation( super.service( "Quotation" ).get( json.quotationId ) );
		bean.setQuotationZone( super.service( "QuotationZone" ).get( json.quotationItem.quotationZone.id ) );
		bean.setQuantity( json.quotationItem.quantity );
		bean.setCustomImage( json.quotationItem.customImage );

		if( Len( json.quotationItem?.position?.code ) ) {
			var position = populatePositionBean( json.quotationItem.position );
			bean.setPosition( position );
		} else  {
			bean.setPosition( null );
		}


		var product = super
			.fire(
				"Product.search",
				{
					lineId     = json.signageConfig.catalogBundle.line.id,
					modelId    = json.signageConfig.catalogBundle.model.id,
					categoryId = json.signageConfig.catalogBundle.category.id,
					finishId   = json.quotationItem.product.finish.id
				}
			)
			.getData();
		
		product = product[ 1 ];
		
		bean.setProduct( super.fire( "Product.get", { "productId" = product.getId() } ) );

		var message = 'Errore durante il salvataggio della segnaletica.'
		transaction {
			if ( !Len( id ) ) {
				messageId = "quotationItem.created";
				thisId    = super.fire( "quotationItem.create", [ bean ] )
			} else {
				messageId = "quotationItem.updated";
				thisId    = super.fire( "quotationItem.update", [ bean ] );
				if ( !IsNull( bean.getInstanceGroupId() ) && Len( bean.getInstanceGroupId() ) ) {
					super.fire( "QuotationItem.syncInstanceGroup", { quotationItemId = thisId } );
				}
			}

			for ( var signageRow in json.quotationItem.signageRows._data ) {
				var signageRowBean = super.fire(
					"QuotationItemSignageRow.get",
					{ quotationItemSignageRowId = signageRow.id }
				);

				if ( !Len( signageRowBean ) ) {
					var signageRowBean = super.bean( "QuotationItemSignageRow" );
					var messaggiId     = "QuotationItemSignageRow.create";
				} else {
					var messaggiId = "QuotationItemSignageRow.update";
				}

				signageRowBean.setQuotationItemId( thisId );
				signageRowBean.setTextAlign( signageRow.textAlign );
				signageRowBean.setContent( signageRow.content );
				signageRowBean.setCharCount( signageRow.charCount );
				signageRowBean.setOrderby( signageRow.index );

				super.fire( messaggiId, [ signageRowBean ] );
			}

			var quotationItemProductItems = super.fire(
				"quotationItemProductItem.list",
				{ quotationItemId = thisId }
			);

			quotationItemProductItems.each( function( quotationItemProductItem ){
				super.fire(
					"quotationItemProductItem.delete",
					{ "productItemId" = quotationItemProductItem.getId() }
				)
			} );

			var _items2 = json.quotationItem.product.items ?: [];
			var productItemsData = isArray( _items2 ) ? _items2 : ( structKeyExists( _items2, "_data" ) ? _items2._data : [] );
			productItemsData.each( function( productItemRow ){
				var selectedValue = selectedValues = ArrayFilter( productItemRow.values, function( v ){
					return v.selected;
				} )
				if ( Len( selectedValue ) > 0 ) {
					selectedValue   = selectedValue[ 1 ];
					var productItem = super.fire(
						"productItem.get",
						{ "productItemId" = selectedValue.product_item_id }
					);

					var quotationItemProductItemBean = super.bean( "quotationItemProductItem" );

					quotationItemProductItemBean.setQuotationItemId( thisId );
					quotationItemProductItemBean.setProductItem( productItem );
					quotationItemProductItemBean.setOrigin( productItem.getOrigin() );
					quotationItemProductItemBean.setLevel( productItemRow.level );
					if (structKeyExists(productItemRow, 'note')) {
						quotationItemProductItemBean.setNote( productItemRow.note );
					}
					quotationItemProductItemBean.setId( thisId )

					super.fire(
						"quotationItemProductItem.create",
						{ "productItem" = quotationItemProductItemBean }
					)
				}
			} )

			super.fire( "quotationItem.aggiornaPrezzoAltriArticoliByQuotationIdLineIdFinishId", {
				"quotationId" = json.quotationId, 
				"quotationItemId" = thisId, 
				"lineId" = json.signageConfig.catalogBundle.line.id,
				"finishId" = json.quotationItem.product.finish.id 
				} 
			);
			message = completeMessage( messageId );
		}

		saveImage( imageBase64 = json.imageBase64, quotationItemId = thisId, typeId = "signage" );

		if ( !Len( id ) ) {
			var productHash = super.fire('ProductHash.createHash', { quotationItemId = thisId });
			super.fire('quotationItem.updateHash', { quotationItemId = thisId, hash = productHash });
		}

		result.setData( { "message" = message, "id" = thisId } );

		event.setValue( "result", result );
	}

	function savePlate( event, rc, prc ){
		setting requestTimeout=120;
		var json      = DeserializeJSON( GetHTTPRequestData().content );
		var thisId    = "";
		var messageId = "";

		var result = super.getResult();
		var tmpDir = super.getTempDir();
		
		var status      = super.bean( "Status" );
		var zone        = super.bean( "QuotationZone" );
		var bean        = super.bean( "QuotationItemPlate" );
		var frame       = super.bean( "Frame" );
		var orientation = super.bean( "Orientation" );

		var beanFruits = [];

		var id = json.item.id;

		if ( Len( id ) ) {
			var bean = duplicate( super.fire( "QuotationItem.get", { quotationItemId = id } ) );
		}

		bean.setQuotation( super.fire( "Quotation.get", [ json.quotationId ] ) ); //TODO: move to QuotationId
		
		bean.setQuantity( json.item.quantity );
		bean.setStatus( status.setId( json.item.status.id ) );
		bean.setQuotationZone( zone.setId( json.item.quotationZone.id ) );
		bean.setSpecial( json.item.special );
		bean.setCustomImage( json.item.customImage );
		bean.setFrame( frame.setOrientation( orientation.setId( json.item.product.orientation.id ) ) );
		bean.setNote( json.item.note )

		// override orientamento dei singoli blocchi (placche a blocchi)
		if ( !IsNull( json.item.blockOrientations ) && IsStruct( json.item.blockOrientations ) && !StructIsEmpty( json.item.blockOrientations ) ) {
			bean.setBlockOrientations( SerializeJSON( json.item.blockOrientations ) );
		} else {
			bean.setBlockOrientations( "" );
		}

		if( Len( json.item?.position?.code ) ) {
			var position = populatePositionBean( json.item.position );
			bean.setPosition( position );
		}

		var pricing = super.fire( 'QuotationItem.getPlatePricing', { 'data' = json } );

		bean.setPrice( pricing );
		
		var product = super.fire( "Product.search",
				{
					categoryId = 22,
					lineId     = json.item.product.line.id,
					modelId    = json.item.product.model.id,
					finishId   = json.item.product.finish.id
				}
			).getData();

		product = product[ 1 ];

		bean.setProduct( product );

		for ( var thisFruit in json.item.fruits._data ) {

			var positions = json.positions[ thisFruit.id ];
			
			/*
				INFO:
				se id è numerico: è stato già salvato nel db
				se id è stringa: è stato agenerato da js per il dnd, record nuovo
			*/
			if ( IsNumeric( thisFruit.id ) && !json.isClone ) {
				// update
				var fruitBean = super.fire( "QuotationItemFruit.get", [ thisFruit.id ] );
			} else {
				// create
				var fruitBean = super.bean( "QuotationItemFruit" );
			}

			var product = super.fire( "product.get", [ thisFruit.fruit.id ] );

			fruitBean.setFruit( product );
			fruitBean.setPositions( positions );

			var items = [];

			var _fruitItems = thisFruit.items ?: [];
			var fruitProductItemsData = isArray( _fruitItems ) ? _fruitItems : ( structKeyExists( _fruitItems, "_data" ) ? _fruitItems._data : [] );

			fruitProductItemsData.each( function( productItemRow ){
				var selectedValue = selectedValues = ArrayFilter( productItemRow.values, function( value ){
					return value.selected;
				} )

				if ( Len( selectedValue ) > 0 ) {
					selectedValue = selectedValue[ 1 ];

					var productItemBean = super.bean( "QuotationItemProductItem" );
					var productItem     = super.fire( "productItem.get", { "productItemId" = selectedValue.productItemId } );

					//productItemBean.setQuotationItemFruitId( fruitBean.getId() );
					productItemBean.setProductItem( productItem );
					productItemBean.setOrigin( productItem.getOrigin() );
					if (structKeyExists(selectedValue, 'note')) {
						productItemBean.setNote( selectedValue.note );
					}
					productItemBean.setLevel( productItemRow.level );

					items.add( productItemBean );
				}
			} );
			
			fruitBean.setItems( items );

			beanFruits.add( fruitBean );

		}

		var plugBeans = super.fire( "QuotationItem.buildPlugFruitBeans", { "data" = json } );
		for ( var plugBean in plugBeans ) {
			beanFruits.add( plugBean );
		}

		bean.setFruits( beanFruits );

		var message = 'Errore durante il salvataggio della placca.'
		transaction {
			if ( !Len( id ) OR json.isClone ) {
				messageId = "quotationItem.created";
				thisId    = super.fire( "quotationItem.create", [ bean ] )
			} else {
				messageId = "quotationItem.updated";
				thisId    = super.fire( "quotationItem.update", [ bean ] );
				if ( !IsNull( bean.getInstanceGroupId() ) && Len( bean.getInstanceGroupId() ) ) {
					super.fire( "QuotationItem.syncInstanceGroup", { quotationItemId = thisId } );
				}
			}

			var quotationItemProductItems = super.fire( "quotationItemProductItem.list", { quotationItemId = thisId });

			quotationItemProductItems.each( function( quotationItemProductItem ){
				super.fire( "quotationItemProductItem.delete", { "productItemId" = quotationItemProductItem.getId() } )
			} );

			var _items3 = json.item.product.items ?: [];
			var productItemsData = isArray( _items3 ) ? _items3 : ( structKeyExists( _items3, "_data" ) ? _items3._data : [] );

			productItemsData.each( function( productItemRow ){
				var selectedValue = selectedValues = ArrayFilter( productItemRow.values, function( value ){
					return value.selected;
				} )

				if ( Len( selectedValue ) > 0 ) {
					selectedValue = selectedValue[ 1 ];

					var productItemBean = super.bean( "QuotationItemProductItem" );
					var productItem     = super.fire( "productItem.get", { "productItemId" = selectedValue.productItemId } );

					productItemBean.setQuotationItemId( thisId );
					productItemBean.setProductItem( productItem );
					productItemBean.setOrigin( productItem.getOrigin() );
					if (structKeyExists(selectedValue, 'note')) {
						productItemBean.setNote( selectedValue.note );
					}
					productItemBean.setLevel( productItemRow.level );
					// productItemBean.setId( thisId )

					super.fire( "quotationItemProductItem.create", [ productItemBean ] )
				}
			} );


			//Funzione che riceve quotationItemId, quotationId, line e finish e aggiorna tutte le righe con quotationItemId <> da quotationItemId e stessa line e finish con i dati del quotationItem con id = quotationItemId
			//che condividono quotation,line e finish, ripartendo il fixed_cost sulla nuova quantita totale
			super.fire( "quotationItem.aggiornaPrezzoAltriArticoliByQuotationIdLineIdFinishId", {
				"quotationId" = json.quotationId, 
				"quotationItemId" = thisId, 
				"lineId" = json.item.product.line.id,
				"finishId" = json.item.product.finish.id 
				} 
			);
			
			message = completeMessage( messageId );
		}

		saveImage( imageBase64 = json.imageBase64, quotationItemId = thisId, typeId = "plate" );

		if ( !Len( id ) OR json.isClone ) {
			var productHash = super.fire('ProductHash.createHash', { quotationItemId = thisId });
			super.fire('quotationItem.updateHash', { quotationItemId = thisId, hash = productHash });
		}

		result.setData( { "message" = message, "id" = thisId } );

		event.setValue( "result", result );
	}

	function duplicate( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );
		var id     = rc.id;
		var asInstance = IsBoolean( json.asInstance ?: false ) ? json.asInstance : false;

		try {
			var newId = super.fire( "QuotationItem.clone", { quotationItemId = id, asInstance = asInstance } );

			// Se viene passata la posizione originale, aggiorna la prima posizione del clone con le stesse coordinate e visibilità
			if ( !IsNull( json.position ?: NullValue() ) ) {
				var newItem = super.fire( "QuotationItem.get", [ newId ] );
				var newPositions = newItem.getPositions();
				if ( !IsNull( newPositions ) && newPositions.len() > 0 ) {
					var firstPos = newPositions[ 1 ];
					firstPos.setCoordinateX( Val( json.position.coordinateX ) );
					firstPos.setCoordinateY( Val( json.position.coordinateY ) );
					firstPos.setVisible( json.position.visible == true || json.position.visible == 1 );
					firstPos.setAngle( Int( Val( json.position.angle ?: 0 ) ) );
					firstPos.setSizeMultiplier( Int( Val( json.position.sizeMultiplier ?: 100 ) ) );
					super.fire( "QuotationItemPosition.update", [ firstPos ] );
				}
			}

			result.setData( { "id" = newId, "message" = "Articolo duplicato correttamente." } );
		} catch ( any e ) {
			result.setStatus( "ERROR" );
			result.setData( { "message" = "Errore durante la duplicazione: #e.message#" } );
		}

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result     = super.getResult();
		var validation = getValidationResult();

		var id = GetHTTPRequestData().content;

		var quotationItem = super.fire( "quotationItem.get", [ id ]);
		var quotationId = quotationItem.getQuotation().getId()
		if (isNull(quotationItem.getArticle())) {
			var lineId = quotationItem.getProduct().getLine().getId()
			var finishId = quotationItem.getProduct().getFinish().getId()
			var productId = quotationItem.getProduct().getId()
		}

		transaction {
			var outcome = super.fire( "quotationItem.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				var error = super.getValidationError(
					message = getMessage( "quotationItem.notDeleted" ),
					field   = "general"
				);
				validation.addError( error );

				event.setValue( "result", validation );
				return;
			}

			if (IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemPlate") || IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemSignage")) {
				super.fire( "quotationItem.aggiornaPrezzoAltriArticoliByQuotationIdLineIdFinishId", {
					"quotationId" = quotationId,
					"quotationItemId" = id, 
					"lineId" = lineId,
					"finishId" = finishId
					} 
				);
			} elseif (isNull(quotationItem.getArticle())) {
				super.fire( "quotationItem.aggiornaPrezzoAltriArticoliByQuotationIdAndProductId", {
					"quotationId" = quotationId,
					"quotationItemId" = id, 
					"productId" = productId
					} 
				);
			}
			result.setData( { "message" = getMessage( "quotationItem.deleted" ) } );
		}

		event.setValue( "result", result );
	}

	function updateAllPrices( event, rc, prc ){
		var result     = super.getResult();
		var validation = getValidationResult();

		var id = rc.id;

		if (!IsNull(id)) {
			var quotationItems = super.fire( "quotationItem.list", { quotationId = id } );

			transaction {
				for (var quotationItem in quotationItems) {
					if (isNull(quotationItem.getArticle())) {
						super.fire( "quotationItem.aggiornaPrezzo", { "quotationItem" = quotationItem } );
					}
				}
				result.setData( { "message" = getMessage( "quotationItem.deleted" ) } );
			}
		}

		event.setValue( "result", result );
	}

	function productItems( event, rc, prc ){
		var result = super.getResult();
		var memny  = super.getMementify();

		var quotationItemId = rc.id;

		var productItems = super.fire( "QuotationItemProductItem.list", { quotationItemId = quotationItemId } );

		var productItems = memny.convertList( productItems );

		result.setCount( Len( productItems ) );
		result.setData( productItems );

		event.setValue( "result", result );
	}

	function fruitProductItems( event, rc, prc ){
		var result = super.getResult();
		var memny  = super.getMementify();
		
		/*
			INFO:
			se id numerico: è stato già salvato nel db
			se id stringa: è stato agenerato da js per il dnd, record nuovo
		*/
		if( IsNumeric( rc.id ) ) {
			var quotationItemFruitId = rc.id;

			var productItems = super.fire( "QuotationItemProductItem.list", { quotationItemFruitId = quotationItemFruitId } );

			var productItems = memny.convertList( productItems );
			
			result.setCount( Len( productItems ) );
			result.setData( productItems );

		} else {
			result.setCount( 0 );
			result.setData( [] );
		}

		event.setValue( "result", result );
	}

	function calculate( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content )

		if (rc.type == "signage") {
			var price = super.fire( 'QuotationItem.getSignagePricing', { 'data' = json } );
		} elseif(rc.type == "plate") {
			var price = super.fire( 'QuotationItem.getPlatePricing', { 'data' = json } );
		} else {
			var price = super.fire( 'QuotationItem.getPricing', { 'data' = json } );
		}

		var memy = super.getMementify();
		var data = memy.convert( price );

		event.setValue( "result", data );
	}

	private Struct function populatePositionBean( 
			required Struct data
		){
		
		var position = super.bean( "QuotationZonePosition" );

		position.setId( data.id );
		position.setCode( data.code );
		//position.setName( data.name );

		return position;

	}

	private Struct function saveImage( 
			required String imageBase64, 
			required String quotationItemId,
			required String typeId
		){
		
		var tmpDir = getTempDir();

		// INFO: se uso il get qui il servizio crea la cache senza immagine
		// che sarà vuota quando viene serializzata
		//var item = service("QuotationItem").get( arguments.quotationItemId );

		//var type = "accessory";

		/*
		if( IsInstanceOf( item, "com.apirone.core.model.bean.QuotationItemPlate" ) ){
			type = "plate";
		}

		if( IsInstanceOf( item, "com.apirone.core.model.bean.QuotationItemSignage" ) ){
			type = "signage";
		}
		*/

		var fileName   = "preview_" & arguments.typeId & "_id_" & arguments.quotationItemId & ".png";
		var filePath   = tmpDir & "/" & fileName;
		var binaryData = ToBinary( arguments.imageBase64 );

		FileWrite( filePath, binaryData );

		var files = super.fire( "File.search", { quotationItemId = arguments.quotationItemId } );
		
		if ( Len( files.getData() ) ) {
			for ( var file in files.getData() ) {
				super.fire( "File.delete", { fileId = file.getId() } );
			}
		}

		var entity = super.bean( "Entity" );
		
		entity.setKey( "quotationItem.id" );
		entity.setValue( arguments.quotationItemId );

		var fileId = super.fire(
			"file.create",
			{
				filePath = filePath,
				typeId   = "default",
				kindId   = "quotationItem",
				entity   = entity
			}
		);

		var result = {	
			"fileId"   = fileId,
			"fileName" = fileName,
			"type" = arguments.typeId
		};

		return result;

	}

	function reorder( event, rc, prc ){
		var result = super.getResult();
		var json   = DeserializeJSON( GetHTTPRequestData().content );

		super.fire( "QuotationItem.reorder", { ids = json.ids } );

		result.setData( {} );
		event.setValue( "result", result );
	}

	private String function getTypeIdBySlug(
			required String slug
		){

		var params = {
			"plate"     = "PLA",
			"accessory" = "ACC",
			"signage"   = "SEG",
			"article"   = "ART"
		}

		return params[ arguments.slug ];		

	}

}
