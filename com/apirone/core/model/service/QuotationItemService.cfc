component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemDAO";
	property name="quotationItemFruitService" inject="QuotationItemFruitService";
	property name="quotationItemPriceService" inject="QuotationItemPriceService";
	property name="QuotationService" inject="QuotationService";
	property name="QuotationZoneService" inject="QuotationZoneService";
	property name="QuotationItemProductItemService" inject="QuotationItemProductItemService";
	property name="ProductService" inject="ProductService";
	property name="StatusService" inject="StatusService";
	property name="ArticleService" inject="ArticleService";
	property name="ProductHashService" inject="ProductHashService";
	property name="SignageConfigItemService" inject="SignageConfigItemService";
	property name="FileService" inject="FileService";
	property name="QuotationItemSignageRowService" inject="QuotationItemSignageRowService";
	property name="QuotationZonePositionService" inject="QuotationZonePositionService";
	property name="QuotationItemPositionService" inject="QuotationItemPositionService";
	property name="LookupService" inject="LookupService";
	property name="CatalogBundleService" inject="CatalogBundleService";
	property name="TextService" inject="TextService";
	property name="PriceService" inject="PriceService";
	property name="ProductItemService" inject="ProductItemService";

	public com.apirone.core.model.bean.QuotationItem function get( required String quotationItemId ){
		return build( arguments.quotationItemId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		String mode,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotation.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.quotation_item_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale, applicando il filtro mode
		records.each( function( record ) {
			var quotationItem = beanMap[ record.quotation_item_id ];
			if ( IsNull( mode ) ) {
				rows.add( quotationItem );
			} else {
				if ( mode == "plate" ) {
					if ( IsInstanceOf( quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" ) ) {
						rows.add( quotationItem );
					}
				} else {
					if ( !IsInstanceOf( quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" ) ) {
						rows.add( quotationItem );
					}
				}
			}
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public void function reorder( required Array ids ){
		var ordinamento = 10;
		for ( var id in arguments.ids ) {
			getDao().updateOrdinamento( id, ordinamento );
			ordinamento += 10;
		}
	}

	public com.apirone.core.model.bean.Outcome function delete( required String quotationItemId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemId = arguments.quotationItemId } );

		transaction {
			try {
				getDao().delete( arguments.quotationItemId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItem" );
				outcome.setMessage( "Cannot delete quotation item [#arguments.quotationItemId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItem quotationItem ){

		transaction {

			arguments.quotationItem = ensurePosition( arguments.quotationItem );

			if ( !IsNumeric( arguments.quotationItem.getOrdinamento() ) || arguments.quotationItem.getOrdinamento() == 0 ) {
				if ( !isNull( arguments.quotationItem.getArticle() ) ) {
					var typeId = "ART";
				} else if ( IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" ) ) {
					var typeId = "PLA";
				} else if ( IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemSignage" ) ) {
					var typeId = "SEG";
				} else {
					var typeId = "ACC";
				}
				var maxOrd = getDao().getMaxOrdinamento( arguments.quotationItem.getQuotation().getId(), typeId );
				arguments.quotationItem.setOrdinamento( maxOrd + 10 );
			}

			var newId = getDao().insert( arguments.quotationItem );

			if ( IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" ) ) {
				for ( var thisFruit in arguments.quotationItem.getFruits() ) {
					thisFruit.setQuotationItemId( newId );
					thisFruit.setId(null)
					getQuotationItemFruitService().create( thisFruit );
				}
			}

			var price = arguments.quotationItem.getPrice();
			price.setQuotationItemId( newId );
			getQuotationItemPriceService().create( price );

			if ( isNull( arguments.quotationItem.getArticle() ) ) {
				var hash = getProductHashService().createHash( newId );
				if ( !IsNull( hash ) ) {
					updateHash( newId, hash );
				}
			}

			if (isNull(quotationItem.getArticle())) {
				var quotationItemQuantity = arguments.quotationItem.getQuantity();
				if (quotationItemQuantity > 0) {
					for (var i = 1; i <= quotationItemQuantity; i++) {
						var position = super.bean("QuotationItemPosition");
						position.setQuotationItemId(newId);
						getQuotationItemPositionService().create(position);
					}
				}
			}

		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItem quotationItem ){

		var oldBean = get( arguments.quotationItem.getId() );

		if ( IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" ) ) {
			var fruitIdsToDeleted = [];

			for ( var thisFruit in oldBean.getFruits() ) {
				var found = false;
				for ( var newFruit in arguments.quotationItem.getFruits() ) {
					if ( !IsNull( thisFruit.getId() ) && thisFruit.getId() == newFruit.getId() ) {
						found = true;
						break;
					}
				}
				if ( !found ) {
					fruitIdsToDeleted.add( thisFruit.getId() );
				}
			}
		}

		transaction {

			arguments.quotationItem = ensurePosition( arguments.quotationItem );

			getDao().update( arguments.quotationItem );

			if ( IsInstanceOf( arguments.quotationItem, "com.apirone.core.model.bean.QuotationItemPlate" ) ) {
				for( var thisFruitId in fruitIdsToDeleted ) {
					getQuotationItemFruitService().delete( thisFruitId );
				}

				for ( var thisFruit in arguments.quotationItem.getFruits() ) {
					if ( IsNull( thisFruit.getId() ) || thisFruit.getId() == "" ) {
						thisFruit.setQuotationItemId( arguments.quotationItem.getId() );
						getQuotationItemFruitService().create( thisFruit );
					} else {
						getQuotationItemFruitService().update( thisFruit );
					}
				}
			}

			if ( !IsNull( arguments.quotationItem.getPrice() ) ) {

				var current = getQuotationItemPriceService().getByQuotationItemId( arguments.quotationItem.getId() );

				arguments.quotationItem.getPrice().setId( current.getId() );
				arguments.quotationItem.getPrice().setQuotationItemId( arguments.quotationItem.getId() );

				var price = arguments.quotationItem.getPrice();
				getQuotationItemPriceService().update( price );
			}

			if ( isNull( arguments.quotationItem.getArticle() ) ) {
				var hash = getProductHashService().createHash( arguments.quotationItem.getId() );
				if ( !IsNull( hash ) ) {
					updateHash( arguments.quotationItem.getId(), hash );
				}

				var quotationItemQuantity = arguments.quotationItem.getQuantity();
				var countItemPositions = arguments.quotationItem.getPositions();
				if (isNull(countItemPositions)) {
					countItemPositions = 0;
				} else {
					countItemPositions = countItemPositions.len();
				}

				if (quotationItemQuantity > countItemPositions) {
					for (var i = countItemPositions + 1; i <= quotationItemQuantity; i++) {
						var position = super.bean("QuotationItemPosition");
						position.setQuotationItemId(arguments.quotationItem.getId());
						getQuotationItemPositionService().create(position);
					}
				}
				// Logica cancellata provvisoriamente, ora se riduco quantita lo gestisco lato controller, sara possibile eliminare (ridurre qta) solo dalla mappa.
				// else if (quotationItemQuantity < maxSequenceQuotationItemPosition) {
				// 	for (var i = quotationItemQuantity + 1; i <= maxSequenceQuotationItemPosition; i++) {
				// 		var positionToDelete = getQuotationItemPositionService().list( quotationItemId = arguments.quotationItem.getId(), sequence = i );
				// 		if (Len(positionToDelete) > 0) {
				// 			getQuotationItemPositionService().delete(positionToDelete[1].getId());
				// 		}
				// 	}
				// }
			}

		}

		return arguments.quotationItem.getId();
	}


	public Boolean function updateHash( required String quotationItemId, required String hash ){
		getDao().updateHash( quotationItemId, hash );
		return true;
	}

	/**
	 * Ensure quotation item position is created and linked when needed.
	 */
	private com.apirone.core.model.bean.QuotationItem function ensurePosition( required com.apirone.core.model.bean.QuotationItem quotationItem ){

		if ( !IsNull( arguments.quotationItem.getPosition() ) ) {
			if ( Len( arguments.quotationItem.getPosition().getCode() ) ) {

				var position = arguments.quotationItem.getPosition();

				if ( IsNull( position.getId() ) OR !Len( position.getId() ) ) {

					position.setZoneId( arguments.quotationItem.getQuotationZone().getId() );
					var newPositionId = getQuotationZonePositionService().create( position );
					arguments.quotationItem.getPosition().setId( newPositionId );
				}
			}
		}

		return arguments.quotationItem;
	}

	/**
	 * Recupera in batch più QuotationItem dato un array di ID.
	 * Restituisce uno Struct chiave = quotationItemId, valore = bean QuotationItem.
	 * precarica tutte le FK correlate (Quotation, Product, Article, Zone, SignageConfigItem,
	 * Fruits, Prices, Files, ProductItems, SignageRows, Positions) in batch per evitare
	 * il problema N+1, il più pesante di tutta l'applicazione.
	 *
	 * @ids Array di quotationItemId
	 * @return Struct mappato per quotationItemId -> QuotationItem
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// --- Fase 1: raccoglie gli ID delle FK dai record ---
		var quotationIds    = [];
		var productIds      = [];
		var articleIds      = [];
		var zoneIds         = [];
		var signageConfigItemIds = [];
		var zonePositionIds = [];

		for ( var r in records ) {
			if ( !IsNull( r.quotation_id ) ) {
				quotationIds.append( r.quotation_id );
			}
			if ( Len( r.product_id ) ) {
				productIds.append( r.product_id );
			}
			if ( Len( r.article_id ) ) {
				articleIds.append( r.article_id );
			}
			if ( !IsNull( r.quotation_zone_id ) ) {
				zoneIds.append( r.quotation_zone_id );
			}
			if ( Len( r.signage_config_item_id ) ) {
				signageConfigItemIds.append( r.signage_config_item_id );
			}
			if ( Len( r.quotation_zone_position_id ) ) {
				zonePositionIds.append( r.quotation_zone_position_id );
			}
		}

		// --- Fase 2: precarica tutte le entity in batch ---

		// Quotation (getMany() ora esiste e batch-carica Owner, StatusHistory)
		var quotationMap = {};
		if ( ArrayLen( quotationIds ) ) {
			quotationMap = getQuotationService().getMany( quotationIds );
		}

		// Product: precarica in batch con getMany() ottimizzato di ProductService
		var productMap = {};
		if ( ArrayLen( productIds ) ) {
			productMap = getProductService().getMany( productIds );
		}

		// Article
		var articleMap = {};
		if ( ArrayLen( articleIds ) ) {
			articleMap = getArticleService().getMany( articleIds );
		}

		// QuotationZone
		var zoneMap = {};
		if ( ArrayLen( zoneIds ) ) {
			zoneMap = getQuotationZoneService().getMany( zoneIds );
		}

		// SignageConfigItem
		var signageConfigItemMap = {};
		if ( ArrayLen( signageConfigItemIds ) ) {
			signageConfigItemMap = getSignageConfigItemService().getMany( signageConfigItemIds );
		}

		// Fruits: legge i record via DAO, raccoglie i PK, carica con getMany()
		var fruitMap = {};
		if ( ArrayLen( arguments.ids ) ) {
			var fruitRecords = getQuotationItemFruitService().getDao().findByQuotationItemIds( arguments.ids );
			var fruitIds = [];
			var fruitGroup = {};
			for ( var fr in fruitRecords ) {
				fruitIds.append( fr.quotation_item_fruit_id );
				if ( !StructKeyExists( fruitGroup, fr.quotation_item_id ) ) {
					fruitGroup[ fr.quotation_item_id ] = [];
				}
				fruitGroup[ fr.quotation_item_id ].append( fr.quotation_item_fruit_id );
			}
			// Carica i bean completi con getMany() ottimizzato
			if ( ArrayLen( fruitIds ) ) {
				var fruitBeanMap = getQuotationItemFruitService().getMany( fruitIds );
				for ( var qid in fruitGroup ) {
					fruitMap[ qid ] = [];
					for ( var fid in fruitGroup[ qid ] ) {
						if ( StructKeyExists( fruitBeanMap, fid ) ) {
							fruitMap[ qid ].append( fruitBeanMap[ fid ] );
						}
					}
				}
			}
		}

		// Prices (batch via nuovo readByQuotationItemIds)
		var priceMap = {};
		if ( ArrayLen( arguments.ids ) ) {
			var priceRecords = getQuotationItemPriceService().getDao().readByQuotationItemIds( arguments.ids );
			for ( var prr in priceRecords ) {
				// buildFromRow è privato su QuotationItemPriceService: costruzione inline
				var priceBean = super.bean( "QuotationItemPrice" );
				var methodBean = super.bean( "PriceMethod" );
				priceBean.setId( prr.quotation_item_price_id );
				priceBean.setDiscount1( prr.discount1 );
				priceBean.setDiscount2( prr.discount2 );
				priceBean.setAmount( prr.amount );
				priceBean.setMethod( methodBean.setId( prr.price_method_id ) );
				// Lines: non precaricati in batch (non critici per la lista quotazioni)
				priceMap[ prr.quotation_item_id ] = priceBean;
			}
		}

		// Files (listByEntityIds)
		var fileMap = getFileService().listByEntityIds( "quotationItem.id", arguments.ids );

		// ProductItems (batch via DAO, raggruppati per quotationItemId)
		var productItemMap = {};
		if ( ArrayLen( arguments.ids ) ) {
			var idsList = ArrayToList( arguments.ids );
			var qipiRecords = getQuotationItemProductItemService().getDao().readByQuotationItemIds( arguments.ids );

			// Raccoglie i product_item_id e origin_id per precaricamento batch
			var qipiProductItemIds = [];
			var qipiOriginIds      = [];
			for ( var qr in qipiRecords ) {
				if ( !IsNull( qr.product_item_id ) ) {
					qipiProductItemIds.append( qr.product_item_id );
				}
				if ( !IsNull( qr.origin_id ) ) {
					qipiOriginIds.append( qr.origin_id );
				}
			}

			// Precarica i ProductItem in batch con getMany() ottimizzato
			var qipiProductItemMap = {};
			if ( ArrayLen( qipiProductItemIds ) ) {
				qipiProductItemMap = getProductItemService().getMany( qipiProductItemIds );
			}
			// Aggiunge anche gli origin_id alla mappa se non già presenti
			if ( ArrayLen( qipiOriginIds ) ) {
				var missingOriginIds = [];
				for ( var oid in qipiOriginIds ) {
					if ( !StructKeyExists( qipiProductItemMap, oid ) ) {
						missingOriginIds.append( oid );
					}
				}
				if ( ArrayLen( missingOriginIds ) ) {
					var extraOriginMap = getProductItemService().getMany( missingOriginIds );
					for ( var key in extraOriginMap ) {
						qipiProductItemMap[ key ] = extraOriginMap[ key ];
					}
				}
			}

			for ( var qr in qipiRecords ) {
				if ( !StructKeyExists( productItemMap, qr.quotation_item_id ) ) {
					productItemMap[ qr.quotation_item_id ] = [];
				}
				var qipiBean = super.bean( "QuotationItemProductItem" );
				qipiBean.setId( qr.quotation_item_product_item_id );
				qipiBean.setQuotationItemId( qr.quotation_item_id );
				qipiBean.setLevel( qr.level );
				qipiBean.setNote( qr.note );
				// ProductItem: dalla mappa pre-caricata
				if ( !IsNull( qr.product_item_id ) && StructKeyExists( qipiProductItemMap, qr.product_item_id ) ) {
					qipiBean.setProductItem( qipiProductItemMap[ qr.product_item_id ] );
				}
				// Origin: dalla mappa pre-caricata (usa gli stessi ProductItem già caricati)
				if ( !IsNull( qr.origin_id ) && StructKeyExists( qipiProductItemMap, qr.origin_id ) ) {
					qipiBean.setOrigin( qipiProductItemMap[ qr.origin_id ] );
				}
				productItemMap[ qr.quotation_item_id ].append( qipiBean );
			}
		}

		// SignageRows (batch via nuovo readByQuotationItemIds)
		var signageRowMap = {};
		if ( ArrayLen( arguments.ids ) ) {
			var rowRecords = getQuotationItemSignageRowService().getDao().readByQuotationItemIds( arguments.ids );
			for ( var srr in rowRecords ) {
				if ( !StructKeyExists( signageRowMap, srr.quotation_item_id ) ) {
					signageRowMap[ srr.quotation_item_id ] = [];
				}
				var rowBean = super.bean( "QuotationItemSignageRow" );
				rowBean.setId( srr.quotation_item_signage_row_id.toString() );
				rowBean.setQuotationItemId( srr.quotation_item_id.toString() );
				rowBean.setTextAlign( srr.text_align );
				rowBean.setContent( srr.content );
				rowBean.setCharCount( srr.char_count );
				rowBean.setOrderBy( srr.orderby );
				signageRowMap[ srr.quotation_item_id ].append( rowBean );
			}
		}

		// Positions (batch via nuovo readByQuotationItemIds)
		var positionMap = {};
		if ( ArrayLen( arguments.ids ) ) {
			var posRecords = getQuotationItemPositionService().getDao().readByQuotationItemIds( arguments.ids );
			for ( var por in posRecords ) {
				if ( !StructKeyExists( positionMap, por.quotation_item_id ) ) {
					positionMap[ por.quotation_item_id ] = [];
				}
				var posBean = super.bean( "QuotationItemPosition" );
				posBean.setId( por.quotation_item_position_id.toString() );
				posBean.setQuotationItemId( por.quotation_item_id.toString() );
				posBean.setCoordinateX( por.coordinate_x );
				posBean.setCoordinateY( por.coordinate_y );
				posBean.setVisible( por.visible );
				posBean.setAngle( por.angle );
				positionMap[ por.quotation_item_id ].append( posBean );
			}
		}

		// QuotationZonePosition: chiamate individuali (numero basso, non ha getMany)
		var zonePositionCache = {};

		// --- Fase 3: costruisce i bean QuotationItem ---
		for ( var r in records ) {
			// Determina il tipo (Plate, Signage, o base)
			var fruits = [];
			if ( StructKeyExists( fruitMap, r.quotation_item_id ) ) {
				fruits = fruitMap[ r.quotation_item_id ];
				ArraySort( fruits, function( a, b ){
					return a.getPositions()[ 1 ].order - b.getPositions()[ 1 ].order;
				} );
			}

			if ( ArrayLen( fruits ) ) {
				var bean = super.bean( "QuotationItemPlate" );

				bean.setFruits( fruits );

				var frame = super.bean( "Frame" );
				frame.setOrientation( getLookupService().get( "orientation", r.orientation_id ) );
				bean.setFrame( frame );
			} else {
				if ( Len( r.signage_config_item_id ) ) {
					var bean = super.bean( "QuotationItemSignage" );
				} else {
					var bean = super.bean( "QuotationItem" );
				}
			}

			// Pricing: dalla mappa batch (bean costruito inline)
			if ( StructKeyExists( priceMap, r.quotation_item_id ) ) {
				bean.setPrice( priceMap[ r.quotation_item_id ] );
			}

			// Campi diretti
			bean.setId( r.quotation_item_id );
			bean.setQuantity( r.quantity );
			bean.setCreatedAt( r.created_at );
			bean.setNote( r.note );
			bean.setHash( r.hash );
			if ( !IsNull( r.ordinamento ) ) bean.setOrdinamento( r.ordinamento );
			bean.setSpecial( BooleanFormat( Val( r.special ) ) );
			bean.setCustomImage( BooleanFormat( Val( r.custom_image ) ) );

			// Quotation: dalla mappa batch
			if ( Len( r.quotation_id ) && StructKeyExists( quotationMap, r.quotation_id ) ) {
				bean.setQuotation( quotationMap[ r.quotation_id ] );
			}

			// Product: dalla mappa batch
			if ( Len( r.product_id ) && StructKeyExists( productMap, r.product_id ) ) {
				bean.setProduct( productMap[ r.product_id ] );
			}

			// Status (cached)
			if ( Len( r.status_id ) ) {
				bean.setStatus( getStatusService().get( r.status_id ) );
			}

			// Article: dalla mappa batch
			if ( Len( r.article_id ) && StructKeyExists( articleMap, r.article_id ) ) {
				bean.setArticle( articleMap[ r.article_id ] );
			}

			// QuotationZone: dalla mappa batch
			if ( !IsNull( r.quotation_zone_id ) && StructKeyExists( zoneMap, r.quotation_zone_id ) ) {
				bean.setQuotationZone( zoneMap[ r.quotation_zone_id ] );
			}

			// SignageConfigItem: dalla mappa batch
			if ( Len( r.signage_config_item_id ) && StructKeyExists( signageConfigItemMap, r.signage_config_item_id ) ) {
				bean.setSignageConfigItem( signageConfigItemMap[ r.signage_config_item_id ] );

				if ( r.char_count ) {
					bean.getSignageConfigItem().setCharCount( r.char_count );
				}
				if ( r.height_in_pixel ) {
					bean.getSignageConfigItem().setHeightInPixel( r.height_in_pixel );
				}
				if ( r.row_count ) {
					bean.getSignageConfigItem().setRowCount( r.row_count );
				}
			}

			// SignageRows: dalla mappa batch
			if ( StructKeyExists( signageRowMap, r.quotation_item_id ) ) {
				bean.setSignageRows( signageRowMap[ r.quotation_item_id ] );
			}

			// File/image: dalla mappa batch
			if ( StructKeyExists( fileMap, r.quotation_item_id ) && Len( fileMap[ r.quotation_item_id ] ) ) {
				bean.setImage( fileMap[ r.quotation_item_id ][ 1 ] );
			}

			// ProductItems: dalla mappa batch
			if ( StructKeyExists( productItemMap, r.quotation_item_id ) ) {
				bean.setItems( productItemMap[ r.quotation_item_id ] );
			}

			// QuotationZonePosition: chiamata individuale (cache locale)
			if ( Len( r.quotation_zone_position_id ) ) {
				var zpid = r.quotation_zone_position_id;
				if ( !StructKeyExists( zonePositionCache, zpid ) ) {
					zonePositionCache[ zpid ] = getQuotationZonePositionService().get( zpid );
				}
				bean.setPosition( zonePositionCache[ zpid ] );
			}

			// Positions: dalla mappa batch
			if ( StructKeyExists( positionMap, r.quotation_item_id ) ) {
				bean.setPositions( positionMap[ r.quotation_item_id ] );
			}

			map[ r.quotation_item_id ] = bean;
		}

		return map;
	}

	private com.apirone.core.model.bean.QuotationItem function build( required String quotationItemId ){
		var record = getDao().read( arguments.quotationItemId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean QuotationItem a partire da una riga del query.
	 * Le sub-entity (Fruits, Prices, Quotation, Product, Status, Article, Zone, SignageConfigItem, Files, ProductItems, Positions) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.QuotationItem function buildFromRow( required any record ){
		var fruits = getQuotationItemFruitService().list( quotationItemId = arguments.record.quotation_item_id );

		var pricing = super.bean( "QuotationItemPrice" );
		var priceMethod = super.bean( "PriceMethod" );

		if ( fruits.len() > 0 ) {
			arraySort(fruits, function(a, b) {
				return a.getPositions()[1].order - b.getPositions()[1].order;
			});
			var bean = super.bean( "QuotationItemPlate" );
			var frame = super.bean( "Frame" );

			bean.setFruits( fruits )

			frame.setOrientation( getLookupService().get( "orientation", arguments.record.orientation_id ) );
			bean.setFrame( frame );

		} else {

			if ( Len( arguments.record.signage_config_item_id ) ) {
				var bean = super.bean( "QuotationItemSignage" );
			} else {
				var bean = super.bean( "QuotationItem" );
			}

		}

		var pricing = getQuotationItemPriceService().getByQuotationItemId( quotationItemId = arguments.record.quotation_item_id );
		bean.setPrice( pricing );

		bean.setId( arguments.record.quotation_item_id );
		bean.setQuantity( arguments.record.quantity );
		bean.setCreatedAt( arguments.record.created_at );

		bean.setQuotation( getQuotationService().get( arguments.record.quotation_id ) );
		//bean.setPrice( pricing );

		if ( Len( arguments.record.product_id ) ) {
			bean.setProduct( getProductService().get( arguments.record.product_id ) );
		}

		if ( Len( arguments.record.status_id ) ) {
			bean.setStatus( getStatusService().get( arguments.record.status_id ) );
		}

		if ( Len( arguments.record.article_id ) ) {
			bean.setArticle( getArticleService().get( arguments.record.article_id ) );
		}

		bean.setQuotationZone(
			IsNull( arguments.record.quotation_zone_id ) ? NullValue() : getQuotationZoneService().get(
				arguments.record.quotation_zone_id
			)
		);

		if ( Len( arguments.record.signage_config_item_id ) ) {
			bean.setSignageConfigItem( getSignageConfigItemService().get( arguments.record.signage_config_item_id ) );

			if ( arguments.record.char_count ) {
				bean.getSignageConfigItem().setCharCount( arguments.record.char_count );
			}
			if ( arguments.record.height_in_pixel ) {
				bean.getSignageConfigItem().setHeightInPixel( arguments.record.height_in_pixel );
			}
			if ( arguments.record.row_count ) {
				bean.getSignageConfigItem().setRowCount( arguments.record.row_count );
			}

			var signageRows = getQuotationItemSignageRowService().list( quotationItemId = arguments.record.quotation_item_id );
			bean.setSignageRows( signageRows );
		}

		var images = getFileService().list( quotationItemId = arguments.record.quotation_item_id );

		if ( Len( images ) ) {
			bean.setImage( images[ 1 ] );
		}

		var items = getQuotationItemProductItemService().list( quotationItemId = arguments.record.quotation_item_id );

		if ( Len( items ) ) {
			bean.setItems( items );
		}

		bean.setNote( arguments.record.note );
		bean.setHash( arguments.record.hash );
		if ( !isNull( arguments.record.ordinamento ) ) bean.setOrdinamento( arguments.record.ordinamento );
		bean.setSpecial( BooleanFormat( Val( arguments.record.special ) ) );
		bean.setCustomImage( BooleanFormat( Val( arguments.record.custom_image ) ) );

		if( Len( arguments.record.quotation_zone_position_id ) ) {
			bean.setPosition( getQuotationZonePositionService().get( arguments.record.quotation_zone_position_id ) );
		}
		var quotationItemPositions = getQuotationItemPositionService().list( quotationItemId = arguments.record.quotation_item_id );
		if ( Len( quotationItemPositions ) ) {
			bean.setPositions( quotationItemPositions );
		}
		return bean;
	}

	public com.apirone.core.model.bean.QuotationItemPrice function getPlatePricing( required Struct data ){

		var json = arguments.data;

		var pricing = super.bean( "QuotationItemPrice" );
		var method  = super.bean( "PriceMethod" );

		var calculator = super.service( "PriceCalculator" );

		var lines = [];

		pricing.setQuantity( StructKeyExists( json.price, "quantity" ) && Val( json.price.quantity ) ? json.item.quantity : 1 );
		pricing.setDiscount1( Val( json.price.discount1 ) ? json.price.discount1 : 0 );
		pricing.setDiscount2( Val( json.price.discount2 ) ? json.price.discount2 : 0 );

		pricing.setMethod( method.setId( json.price.method.id ) );

        if ( pricing.isFixed() ) {
			pricing.setAmount( Val( json.price.total ) ? json.price.total : 0 );
		} else {
			pricing.setAmount( 0 );
		}

		/*
			plate price
		*/

		var productItemsIds = [];

		var product = json.item.product;

		for ( var item in product.items._data ) {
			for ( var value in item.values ) {
				if ( value.selected ) {
					productItemsIds.add( value.productItemId );
				}
			}
		}

		//TODO debuggare qui per capire cosa fare per il discorso "ok placca senza frutti e aggiunta tappi"
		var quotationItem = null;
		if (json.item.id != "") {
			quotationItem = super.service( "QuotationItem" ).get( json.item.id );
		}

		var quotation = null;
		if (json.quotationId != "") {
			var quotation = super.service( "Quotation" ).get( json.quotationId );
		}

		var platePrice = calculator.calculate(
			product.id,
			json.item.quantity,
			json.item.quotationZone.id,
			productItemsIds,
			0,
			0,
			quotation,
			quotationItem
		);

		var line = super.bean( "QuotationItemPriceLine" );

		line.setName( "Prezzo placca" );
		line.setAmount( platePrice.finalPrice );
		line.setCost( platePrice.totalCost );
		lines.add( line );


		/*
			fruits price
		*/

		for ( var fruit in json.item.fruits._data ) {
			var fruitItemsIds = [];

			var line = super.bean( "QuotationItemPriceLine" );

			for ( var item in fruit.items._data ) {
				for ( var value in item.values ) {
					if ( value.selected ) {
						fruitItemsIds.add( value.productItemId );
					}
				}
			}

			var fruitPrice = calculator.calculate(
				fruit.fruit.id,
				1,
				json.item.quotationZone.id,
				fruitItemsIds,
				0,
				0,
				quotation,
				quotationItem
			);

			line.setName( "#fruit.fruit?.name#" );
			line.setAmount( fruitPrice.finalPrice );
			line.setCost( fruitPrice.totalCost );
			lines.add( line );
		}

		pricing.setLines( lines );

		return pricing;
	}

	public com.apirone.core.model.bean.QuotationItemPrice function getSignagePricing( required Struct data ){
		var json = arguments.data;

		var pricing = super.bean( "QuotationItemPrice" );
		var method  = super.bean( "PriceMethod" );

		var calculator = super.service( "PriceCalculator" );

		var lines = [];

		pricing.setQuotationItemId( json.quotationItem.id );
		pricing.setId( Val( json.quotationItem.price.id ) ? json.quotationItem.price.id : null );
		pricing.setQuantity( Val( json.quotationItem.quantity ) ? json.quotationItem.quantity : 1 );
		pricing.setDiscount1( Val( json.quotationItem.price.discount1 ) ? json.quotationItem.price.discount1 : 0 );
		pricing.setDiscount2( Val( json.quotationItem.price.discount2 ) ? json.quotationItem.price.discount2 : 0 );

		pricing.setMethod( method.setId( json.quotationItem.price.method.id ) );

        if ( json.quotationItem.price.method.id EQ 'F' ) {
			pricing.setAmount( Val( json.quotationItem.price.total ) ? json.quotationItem.price.total : 0 );
		} else {
			pricing.setAmount( 0 );
		}

		/*
			signage price
		*/
		var productItemsIds = [];

		var product = json.quotationItem.product;

		var product = json.quotationItem.product;
		if ( product.keyExists( "items" ) ) {
			for ( var item in product.items._data ) {
				for ( var value in item.values ) {
					if ( value.selected ) {
						productItemsIds.add( value.product_item_id );
					}
				}
			}
		}

		var lettersQuantity = 0;
		for ( var signageRow in json.quotationItem.signageRows._data ) {
			lettersQuantity += Val( signageRow.charCount ) ? signageRow.charCount : 0;
		}

		var quotation = getQuotationService().get( json.quotationId )
		var quotationItem = !isNull(json.quotationItem.id) && json.quotationItem.id != '' ? get( json.quotationItem.id ) : null

		var signagePrice = calculator.calculate(
			product.id,
			json.quotationItem.quantity,
			json.quotationItem.quotationZone.id,
			productItemsIds,
			lettersQuantity,
			json.quotationItem.signageConfigItem.id,
			quotation,
			quotationItem
		);
		var line = super.bean( "QuotationItemPriceLine" );

		line.setName( "Prezzo segnaletica" );
		line.setAmount( signagePrice.finalPrice );
		line.setCost( signagePrice.totalCost );

		lines.add( line );

		pricing.setLines( lines );

		return pricing;
	}

	public com.apirone.core.model.bean.QuotationItemPrice function getPricing( required Struct data ){
		var json = arguments.data;

		var pricing = super.bean( "QuotationItemPrice" );
		var method  = super.bean( "PriceMethod" );

		var calculator = super.service( "PriceCalculator" );

		var lines = [];

		pricing.setQuotationItemId( json.quotationItem.id );
		pricing.setId( Val( json.quotationItem.price.id ) ? json.quotationItem.price.id : null );
		pricing.setQuantity( Val( json.quotationItem.quantity ) ? json.quotationItem.quantity : 1 );
		pricing.setDiscount1( Val( json.quotationItem.price.discount1 ) ? json.quotationItem.price.discount1 : 0 );
		pricing.setDiscount2( Val( json.quotationItem.price.discount2 ) ? json.quotationItem.price.discount2 : 0 );

		pricing.setMethod( method.setId( json.quotationItem.price.method.id ) );

        if ( json.quotationItem.price.method.id EQ 'F' ) {
			pricing.setAmount( Val( json.quotationItem.price.total ) ? json.quotationItem.price.total : 0 );
		} else {
			pricing.setAmount( 0 );
		}

		/*
			price
		*/

		var productItemsIds = [];

		var product = json.quotationItem.product;
		if ( product.keyExists( "items" ) ) {
			for ( var item in product.items._data ) {
				for ( var value in item.values ) {
					if ( value.selected ) {
						productItemsIds.add( value.product_item_id );
					}
				}
			}
		}

		var quotation = getQuotationService().get( json.quotationId )
		var quotationItem = !isNull(json.quotationItem.id) && json.quotationItem.id != '' ? get( json.quotationItem.id ) : null

		var price = calculator.calculate(
			product.id,
			json.quotationItem.quantity,
			json.quotationItem.quotationZone.id,
			productItemsIds,
			0,
			0,
			quotation,
			quotationItem
		);

		var line = super.bean( "QuotationItemPriceLine" );

		line.setName( "Prezzo base" );
		line.setAmount( price.finalPrice );
		line.setCost( price.totalCost );

		lines.add( line );

		pricing.setLines( lines );

		return pricing;
	}

	public function getAltreRigheByQuotationLineIdAndFinishId(
		required String quotationItemId,
		required String quotationId,
		required String lineId,
		required String finishId
	){
		if ( IsNull( quotationId ) ) {
			return [];
		}
		return getDao().getAltreRigheByQuotationLineIdAndFinishId(argumentCollection = arguments);
	}

	public function getAltreRigheByQuotationAndProductId(
		required String quotationItemId,
		required String quotationId,
		required String productId
	){
		if ( IsNull( quotationId ) ) {
			return [];
		}
		return getDao().getAltreRigheByQuotationAndProductId(argumentCollection = arguments);
	}

	public function aggiornaPrezzoAltriArticoliByQuotationIdLineIdFinishId(
		required String quotationItemId,
		required String quotationId,
		required String lineId,
		required String finishId
	){
		var rows = this.getAltreRigheByQuotationLineIdAndFinishId(
			"quotationItemId" = quotationItemId,
			"quotationId" = quotationId,
			"lineId" = lineId,
			"finishId" = finishId
		)

		for (var row in rows) {
			var data = {}
			var quotationItem = get( quotationItemId = row.quotation_item_id );
			if (
				!IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemPlate") &&
				!IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemSignage")
			) {
				continue;
			}

			aggiornaPrezzo(quotationItem)
		}
	}

	public function aggiornaPrezzoAltriArticoliByQuotationIdAndProductId(
		required String quotationItemId,
		required String quotationId,
		required String productId
	){
		var rows = this.getAltreRigheByQuotationAndProductId(
			"quotationItemId" = quotationItemId,
			"quotationId" = quotationId,
			"productId" = productId
		)

		for (var row in rows) {
			var data = {}
			var quotationItem = get( quotationItemId = row.quotation_item_id );
			if (
				IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemPlate") ||
				IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemSignage") ||
				!isNull(quotationItem.getArticle())
			) {
				continue;
			}

			aggiornaPrezzo(quotationItem)
		}
	}

	public function aggiornaPrezzo( required quotationItem )
	{
		if (!isNull(quotationItem.getArticle())) {
			return false;
		}
		var quotationId = quotationItem.getQuotation().getId()
		var productId = quotationItem.getProduct().getId();
		var quantity = quotationItem.getQuantity();
		var productItemIds = [];
		if (!isNull(quotationItem.getItems())) {
			for (var item in quotationItem.getItems()) {
				productItemIds.append(item.getProductItem().getId())
			}
		}

		//questa parte serve per replicare le strutture dati che si aspettano getSignagePricing e la getPlatePricing quando chiamate dal client
		if (IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemPlate")) {
			var json =
			{
				"quotationId": "",
				"price": {
					"quantity": 0,
					"discount1": 0,
					"discount2": 0,
					"total": 0,
					"method": { "id": "" }
				},
				"item": {
					"id": "",
					"quantity": 0,
					"product": {
						"id": "",
						"items": { "_data": [] }
					},
					"quotationZone": {
						"id": ""
					},
					"fruits": { "_data": [] }
				}
			}
			json.quotationId = quotationId;
			json.item.id = quotationItem.getId();
			json.item.quotationZone.id = quotationItem.getQuotationZone().getId();
			json.item.quantity = quantity;
			if (!isNull(quotationItem.getPrice())) {
				json.price.id = quotationItem.getPrice().getId();
				json.price.discount1 = quotationItem.getPrice().getDiscount1();
				json.price.discount2 = quotationItem.getPrice().getDiscount2();
				json.price.method.id = quotationItem.getPrice().getMethod().getId();
				json.price.total = quotationItem.getPrice().getMethod().getId() == "F" ? quotationItem.getPrice().getAmount() : 0;
			}
			json.item.product.id = productId;
			for (productItemId in productItemIds) {
				json.item.product.items._data.append({
					values = [
						{ selected = true, productItemId = productItemId }
					]
				});
			}
			var fruits = quotationItem.getFruits();
			for (var fruit in fruits) {
				var fruitItems = []

				if ( !isNull( fruit.getItems() ) ) {
					for (fruitItem in fruit.getItems()) {
						fruitItems.append({
							values = [
								{ selected = true, productItemId = fruitItem.getProductItem().getId() }
							]
						})
					}
				}
				json.item.fruits._data.append({
					"fruit": {
						"name": fruit.getFruit().getName(),
						"id": fruit.getFruit().getId()
					},
					"fruitId": fruit.getId(),
					"items": { "_data": fruitItems }
				});
			}
			var price = getPlatePricing(json)
		}

		if (IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemSignage")) {
			json = {
				"quotationId": "",
				"quotationItem": {
					"id": "",
					"quantity": 0,
					"price": {
						"id": 0,
						"discount1": 0,
						"discount2": 0,
						"method": { "id": "F" },
						"total": 0
					},
					"quotationZone": {
						"id": ""
					},
					"product": {
						"id": "",
					"items": { "_data": [] }
					},
					"signageRows": { "_data": [] },
					"signageConfigItem": { "id": 0 }
				}
			}

			json.quotationId = quotationId;
			json.quotationItem.id = quotationItem.getId()
			json.quotationItem.quotationZone.id = quotationItem.getQuotationZone().getId()
			json.quotationItem.quantity = quantity
			if (!isNull(quotationItem.getPrice())) {
				json.quotationItem.price.id = quotationItem.getPrice().getId();
				json.quotationItem.price.discount1 = quotationItem.getPrice().getDiscount1();
				json.quotationItem.price.discount2 = quotationItem.getPrice().getDiscount2();
				json.quotationItem.price.method.id = quotationItem.getPrice().getMethod().getId();
				json.quotationItem.price.total = quotationItem.getPrice().getMethod().getId() == "F" ? quotationItem.getPrice().getAmount() : 0;
			}
			json.quotationItem.product.id = productId;
			for (productItemId in productItemIds) {
				json.quotationItem.product.items._data.append({
					values = [
						{ selected = true, product_item_id = productItemId }
					]
				});
			}

			json.quotationItem.signageConfigItem.id = quotationItem.getSignageConfigItem().getId()
			for ( var signageRow in quotationItem.getSignageRows() ) {
				json.quotationItem.signageRows._data.append({ charCount = signageRow.getCharCount() });
			}
			var price = getSignagePricing(json)
		} elseif (isNull(quotationItem.getArticle()) && !IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemPlate")) {
			json = {
				"quotationId": "",
				"quotationItem": {
					"id": "",
					"quantity": 0,
					"price": {
						"id": 0,
						"discount1": 0,
						"discount2": 0,
						"method": { "id": "F" },
						"total": 0
					},
					"quotationZone": {
						"id": ""
					},
					"product": {
						"id": "",
					"items": { "_data": [] }
					}
				}
			}

			json.quotationId = quotationId;
			json.quotationItem.id = quotationItem.getId()
			json.quotationItem.quotationZone.id = quotationItem.getQuotationZone().getId()
			json.quotationItem.quantity = quantity
			if (!isNull(quotationItem.getPrice())) {
				json.quotationItem.price.id = quotationItem.getPrice().getId();
				json.quotationItem.price.discount1 = quotationItem.getPrice().getDiscount1();
				json.quotationItem.price.discount2 = quotationItem.getPrice().getDiscount2();
				json.quotationItem.price.method.id = quotationItem.getPrice().getMethod().getId();
				json.quotationItem.price.total = quotationItem.getPrice().getMethod().getId() == "F" ? quotationItem.getPrice().getAmount() : 0;
			}
			json.quotationItem.product.id = productId;
			for (productItemId in productItemIds) {
				json.quotationItem.product.items._data.append({
					values = [
						{ selected = true, product_item_id = productItemId }
					]
				});
			}
			var price = getPricing(json)
		}

		quotationItem.setPrice( price )
		update(quotationItem)
	}

	public function validateQuantity(
		required Quotation quotation,
		required QuotationItem quotationItem
	) {
		var productMinQuantity = quotationItem.getProduct().getMinQuantity()
		var productMaxQuantity = quotationItem.getProduct().getMaxQuantity()

		var productQuantity = 0
		if (productMinQuantity > 0 || productMaxQuantity > 0) {
			productQuantity = getProductQuantityByQuotation( quotation, quotationItem.getProduct() )
		}

		if ( productQuantity LT productMinQuantity || productQuantity GT productMaxQuantity ) {
			return false;
		}

		return true;
	}

	public function getProductQuantityByQuotation( Quotation quotation, Product product ) {
		var quotationItems = list( quotationId = quotation.getId() )
		var quantity = 0;
		for ( var item in quotationItems ) {
			if (!isNull(item.getArticle())) {
				continue;
			}
			if (item.getProduct().getId() == product.getId() ) {
				quantity += item.getQuantity()
			}
		}

		return quantity;
	}

	public function validateDiscounts(
		required numeric maxUserDiscount,
		required numeric quotationDiscount1,
		required numeric quotationDiscount2,
		required numeric itemDiscount1,
		required numeric itemDiscount2
	) {
		var factor =
			( 1 - arguments.quotationDiscount1 / 100 ) *
			( 1 - arguments.quotationDiscount2 / 100 ) *
			( 1 - itemDiscount1 / 100 ) *
			( 1 - itemDiscount2 / 100 );
		var totalDiscount = ( 1 - factor ) * 100;

		if ( totalDiscount GT arguments.maxUserDiscount ) {
			return false;
		}

		return true;
	}
}
