component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemDAO";
	property name="quotationItemFruitService" inject="QuotationItemFruitService";
	property name="quotationItemPriceService" inject="QuotationItemPriceService";
	property name="quotationItemPriceLineService" inject="QuotationItemPriceLineService";
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

		// Carica il bean esistente via batch getMany() per evitare la cascata N+1
		var beanMap = getMany( [ arguments.quotationItem.getId() ] );
		var oldBean = StructKeyExists( beanMap, arguments.quotationItem.getId() )
			? beanMap[ arguments.quotationItem.getId() ]
			: NullValue();

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
	 * Clona un QuotationItem. Se asInstance=true genera un instance_group_id condiviso
	 * tra l'originale e il clone, in modo da sincronizzarli ad ogni modifica futura.
	 * Restituisce l'ID del nuovo item.
	 */
	public String function clone( required String quotationItemId, Boolean asInstance = false ){
		var original = get( arguments.quotationItemId );

		if ( IsNull( original ) ) {
			throw( message = "QuotationItem non trovato: #arguments.quotationItemId#" );
		}

		// Prepara il clone cancellando l'ID e azzerando l'ordinamento (verrà ricalcolato)
		var cloneBean = duplicate( original );
		cloneBean.setId( "" );
		cloneBean.setOrdinamento( 0 );

		var newInstanceGroupId = "";
		if ( arguments.asInstance ) {
			newInstanceGroupId = lcase( createUUID() );
			cloneBean.setInstanceGroupId( newInstanceGroupId );
		} else {
			cloneBean.setInstanceGroupId( "" );
		}

		// Azzera le posizioni: il clone parte senza posizioni pianta
		cloneBean.setPositions( [] );

		var newId = "";
		transaction {
			newId = create( cloneBean );

			// Se istanza: aggiorna anche l'originale con lo stesso instance_group_id
			if ( arguments.asInstance ) {
				getDao().updateInstanceGroupId( arguments.quotationItemId, newInstanceGroupId );
			}

			// Copia le signage rows se presenti
			if ( IsInstanceOf( cloneBean, "com.apirone.core.model.bean.QuotationItemSignage" ) ) {
				var originalRows = getQuotationItemSignageRowService().list( quotationItemId = arguments.quotationItemId );
				for ( var row in originalRows ) {
					var rowClone = duplicate( row );
					rowClone.setId( "" );
					rowClone.setQuotationItemId( newId );
					getQuotationItemSignageRowService().create( rowClone );
				}
			}
		}

		return newId;
	}

	/**
	 * Sincronizza tutti i QuotationItem con lo stesso instance_group_id di quello dato.
	 * Copia i campi "configurazione articolo" (zona, prodotto, quantità, note, special, prezzo).
	 * NON copia le posizioni pianta (sono specifiche per ogni istanza).
	 */
	public void function syncInstanceGroup( required String quotationItemId ){
		var source = get( arguments.quotationItemId );
		if ( IsNull( source ) || IsNull( source.getInstanceGroupId() ) || !Len( source.getInstanceGroupId() ) ) return;

		var siblings = getDao().findByInstanceGroupId( source.getInstanceGroupId() );
		for ( var row in siblings ) {
			if ( row.quotation_item_id == arguments.quotationItemId ) continue;
			var sibling = get( row.quotation_item_id );
			if ( IsNull( sibling ) ) continue;

			// Copia i campi di configurazione (NO posizioni, NO zona)
			sibling.setQuantity( source.getQuantity() );
			sibling.setNote( source.getNote() );
			sibling.setSpecial( source.getSpecial() );
			sibling.setCustomImage( source.getCustomImage() );
			if ( !IsNull( source.getProduct() ) ) sibling.setProduct( source.getProduct() );
			if ( !IsNull( source.getPrice() ) )   sibling.setPrice( source.getPrice() );

			update( sibling );
		}
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
		var priceMap      = {};
		var priceBeanById = {};
		if ( ArrayLen( arguments.ids ) ) {
			var priceRecords = getQuotationItemPriceService().getDao().readByQuotationItemIds( arguments.ids );
			var priceIds     = [];
			for ( var prr in priceRecords ) {
				var priceBean = super.bean( "QuotationItemPrice" );
				var methodBean = super.bean( "PriceMethod" );
				priceBean.setId( prr.quotation_item_price_id );
				priceBean.setDiscount1( prr.discount1 );
				priceBean.setDiscount2( prr.discount2 );
				priceBean.setAmount( prr.amount );
				priceBean.setMethod( methodBean.setId( prr.price_method_id ) );
				// Mappa sia per quotation_item_id (lookup dal bean) che per price_id (aggiornamento linee)
				priceMap[ prr.quotation_item_id ]             = priceBean;
				priceBeanById[ prr.quotation_item_price_id ]  = priceBean;
				priceIds.append( prr.quotation_item_price_id );
			}

			// Precarica le linee di prezzo in batch (necessarie per getTotal()
			// che somma i line.amount per calcolare il totale)
			if ( ArrayLen( priceIds ) ) {
				var priceLineDao  = getQuotationItemPriceLineService().getDao();
				var priceLineRecs = priceLineDao.readByQuotationItemPriceIds( priceIds );
				for ( var plr in priceLineRecs ) {
					var lineBean = super.bean( "QuotationItemPriceLine" );
					lineBean.setName( plr.name );
					lineBean.setAmount( plr.amount );
					lineBean.setCost( plr.cost );
					if ( StructKeyExists( priceBeanById, plr.quotation_item_price_id ) ) {
						var targetPrice = priceBeanById[ plr.quotation_item_price_id ];
						if ( IsNull( targetPrice.getLines() ) || !ArrayLen( targetPrice.getLines() ) ) {
							targetPrice.setLines( [ lineBean ] );
						} else {
							var existingLines = targetPrice.getLines();
							existingLines.append( lineBean );
							targetPrice.setLines( existingLines );
						}
					}
				}
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
				if ( !IsNull( por.size_multiplier ) ) posBean.setSizeMultiplier( por.size_multiplier );
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

				// Block orientations dalla colonna del record
				if ( !IsNull( r.block_orientations ) && Len( r.block_orientations ) ) {
					bean.setBlockOrientations( r.block_orientations );
				}
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

			// SignageRows: dalla mappa batch (solo per QuotationItemSignage)
			if ( Len( r.signage_config_item_id ) ) {
				bean.setSignageRows( StructKeyExists( signageRowMap, r.quotation_item_id ) ? signageRowMap[ r.quotation_item_id ] : [] );
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

			// InstanceGroup
			if ( !IsNull( r.instance_group_id ) && Len( r.instance_group_id ) ) {
				bean.setInstanceGroupId( r.instance_group_id );
				bean.setInstanceGroupCount( getDao().countByInstanceGroupId( r.instance_group_id ) );
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

		if ( fruits.len() > 0 ) {
			arraySort( fruits, function( a, b ){
				return a.getPositions()[ 1 ].order - b.getPositions()[ 1 ].order;
			} );
			var bean = super.bean( "QuotationItemPlate" );
			var frame = super.bean( "Frame" );

			bean.setFruits( fruits );

			frame.setOrientation( getLookupService().get( "orientation", arguments.record.orientation_id ) );
			bean.setFrame( frame );

			if ( !IsNull( arguments.record.block_orientations ) && Len( arguments.record.block_orientations ) ) {
				bean.setBlockOrientations( arguments.record.block_orientations );
			}
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

		if ( !IsNull( arguments.record.instance_group_id ) && Len( arguments.record.instance_group_id ) ) {
			bean.setInstanceGroupId( arguments.record.instance_group_id );
			bean.setInstanceGroupCount( getDao().countByInstanceGroupId( arguments.record.instance_group_id ) );
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

		var productItemsData = isArray( product.items ) ? product.items : product.items._data;
		for ( var item in productItemsData ) {
			for ( var value in item.values ) {
				if ( value.selected ) {
					productItemsIds.add( value.productItemId );
				}
			}
		}

		//TODO debuggare qui per capire cosa fare per il discorso "ok placca senza frutti e aggiunta tappi"
		var quotationItem = null;
		if (json.item.id != "") {
			var qiMap = getMany( [ json.item.id ] );
			quotationItem = StructKeyExists( qiMap, json.item.id )
				? qiMap[ json.item.id ]
				: null;
		}

		var quotation = null;
		if (json.quotationId != "") {
			var qMap = super.service( "Quotation" ).getMany( [ json.quotationId ] );
			quotation = StructKeyExists( qMap, json.quotationId )
				? qMap[ json.quotationId ]
				: null;
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

		if ( isVitiAVistaNo( json ) ) {
			for ( var plug in computePlugRuns( json ) ) {
				var plugProductId = ( plug.type == "tappo" )
					? "5f4ec169-c445-40a0-8c94-1dc22c21be79"
					: "452e03e4-ddf4-4042-ac87-b0f17489c4e1";
				var plugProduct = super.service( "Product" ).get( plugProductId );
				if ( IsNull( plugProduct ) ) continue;
				var plugPrice = calculator.calculate(
					plugProductId, 1, json.item.quotationZone.id, [], 0, 0, quotation, quotationItem
				);
				var plugLine = super.bean( "QuotationItemPriceLine" );
				plugLine.setName( plug.type == "tappo" ? "Tappo" : "Mezzo tappo" );
				plugLine.setAmount( plugPrice.finalPrice );
				plugLine.setCost( plugPrice.totalCost );
				lines.add( plugLine );
			}
		}

		pricing.setLines( lines );

		return pricing;
	}

	private Boolean function isVitiAVistaNo( required Struct json ) {
		if ( !StructKeyExists( json, "item" )
			|| !StructKeyExists( json.item, "product" )
			|| !StructKeyExists( json.item.product, "items" )
			|| !StructKeyExists( json.item.product.items, "_data" ) ) {
			return false;
		}
		for ( var item in json.item.product.items._data ) {
			if ( StructKeyExists( item, "attributeName" ) && item.attributeName == "VITI A VISTA" ) {
				for ( var val in item.values ) {
					if ( StructKeyExists( val, "selected" ) && val.selected
						&& StructKeyExists( val, "attributeValue" )
						&& StructKeyExists( val.attributeValue, "rawValue" )
						&& val.attributeValue.rawValue.name == "NO" ) {
						return true;
					}
				}
			}
		}
		return false;
	}

	private Array function computePlugRuns( required Struct json ) {
		var result = [];
		if ( !StructKeyExists( json, "positions" )
			|| !StructKeyExists( json, "item" )
			|| !StructKeyExists( json.item, "product" )
			|| !StructKeyExists( json.item.product, "frame" )
			|| !StructKeyExists( json.item.product, "orientation" )
			|| !Len( json.item.product.orientation.id ) ) {
			return result;
		}
		// frame.code usato direttamente (path aggiornaPrezzo); frame.id come fallback (path save da client)
		var frameCode = "";
		var frame = "";
		if ( StructKeyExists( json.item.product.frame, "id" ) && Len( json.item.product.frame.id ) ) {
			frame = super.service( "Frame" ).get( json.item.product.frame.id );
		} else if ( StructKeyExists( json.item.product.frame, "code" ) && Len( json.item.product.frame.code ) ) {
			frame = super.service( "Frame" ).getByCode( json.item.product.frame.code );
		}
		if ( !IsNull( frame ) && !IsSimpleValue( frame ) ) frameCode = frame.getCode();
		if ( !Len( frameCode ) && StructKeyExists( json.item.product.frame, "code" ) ) frameCode = json.item.product.frame.code;
		if ( !Len( frameCode ) ) return result;

		var allPositions = [];

		if ( !IsNull( frame ) && !IsSimpleValue( frame ) && !IsNull( frame.getBlocks() ) && ArrayLen( frame.getBlocks() ) ) {
			// placca a blocchi: slot numerati 1..N, indipendenti dall'orientamento.
			// Il blocco serve per non far "cavallottare" un tappo doppio fra due blocchi.
			var slotCounter = 0;
			var blockIndex = 0;
			for ( var block in frame.getBlocks() ) {
				blockIndex++;
				for ( var i = 1; i <= block.getSlotCount(); i++ ) {
					slotCounter++;
					allPositions.add( { id: slotCounter, order: slotCounter - 1, block: blockIndex } );
				}
			}
		} else {
			// placca legacy su file
			var gridFile = ExpandPath( "/config/data/plates/grid_#frameCode#.json.cfm" );
			if ( !FileExists( gridFile ) ) return result;
			var gridConfig = DeserializeJSON( FileRead( gridFile ) );
			var orientationId = json.item.product.orientation.id;
			if ( !StructKeyExists( gridConfig.frame.orientations, orientationId ) ) return result;
			var gridRows = gridConfig.frame.orientations[ orientationId ].grid;
			for ( var gridRow in gridRows ) {
				for ( var cell in gridRow ) {
					if ( cell.type != "0" ) {
						allPositions.add( { id: cell.id, order: cell.order, block: 0 } );
					}
				}
			}
		}

		ArraySort( allPositions, function( a, b ) {
			if ( a.order < b.order ) return -1;
			if ( a.order > b.order ) return 1;
			return 0;
		} );
		var occupiedIds = {};
		for ( var fId in json.positions ) {
			for ( var pos in json.positions[ fId ] ) {
				// posizioni da client: {id: uuid, order: N}; da DB: {position: uuid, order: N}
				var posId = StructKeyExists( pos, "id" ) ? pos.id : ( StructKeyExists( pos, "position" ) ? pos.position : "" );
				if ( Len( posId ) ) occupiedIds[ posId ] = true;
			}
		}
		var emptyPositions = [];
		for ( var pos in allPositions ) {
			if ( !StructKeyExists( occupiedIds, pos.id ) ) {
				emptyPositions.add( pos );
			}
		}
		var idx = 1;
		while ( idx <= ArrayLen( emptyPositions ) ) {
			var isDouble = idx < ArrayLen( emptyPositions )
				&& emptyPositions[ idx + 1 ].order == emptyPositions[ idx ].order + 1
				&& emptyPositions[ idx + 1 ].block == emptyPositions[ idx ].block;
			if ( isDouble ) {
				result.add( { type: "tappo", positionIds: [ emptyPositions[ idx ], emptyPositions[ idx + 1 ] ] } );
				idx += 2;
			} else {
				result.add( { type: "mezzotappo", positionIds: [ emptyPositions[ idx ] ] } );
				idx += 1;
			}
		}
		return result;
	}

	public Array function buildPlugFruitBeans( required Struct data ) {
		var json = arguments.data;
		var result = [];
		if ( !isVitiAVistaNo( json ) ) return result;
		for ( var plug in computePlugRuns( json ) ) {
			var plugProductId = ( plug.type == "tappo" )
				? "5f4ec169-c445-40a0-8c94-1dc22c21be79"
				: "452e03e4-ddf4-4042-ac87-b0f17489c4e1";
			var plugProduct = super.service( "Product" ).get( plugProductId );
			if ( IsNull( plugProduct ) ) continue;
			var fruitBean = super.bean( "QuotationItemFruit" );
			fruitBean.setFruit( plugProduct );
			fruitBean.setPositions( plug.positionIds );
			fruitBean.setItems( [] );
			result.add( fruitBean );
		}
		return result;
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

		if ( product.keyExists( "items" ) ) {
			var productItemsData = isArray( product.items ) ? product.items : product.items._data;
			for ( var item in productItemsData ) {
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

		var qMap = getQuotationService().getMany( [ json.quotationId ] );
		var quotation = StructKeyExists( qMap, json.quotationId )
			? qMap[ json.quotationId ]
			: null;
		var quotationItem = null;
		if ( !isNull( json.quotationItem.id ) && json.quotationItem.id != '' ) {
			var qiMap = getMany( [ json.quotationItem.id ] );
			quotationItem = StructKeyExists( qiMap, json.quotationItem.id )
				? qiMap[ json.quotationItem.id ]
				: null;
		}

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
			var productItemsData = isArray( product.items ) ? product.items : product.items._data;
			for ( var item in productItemsData ) {
				for ( var value in item.values ) {
					if ( value.selected ) {
						productItemsIds.add( value.product_item_id );
					}
				}
			}
		}

		var qMap = getQuotationService().getMany( [ json.quotationId ] );
		var quotation = StructKeyExists( qMap, json.quotationId )
			? qMap[ json.quotationId ]
			: null;
		var quotationItem = null;
		if ( !isNull( json.quotationItem.id ) && json.quotationItem.id != '' ) {
			var qiMap = getMany( [ json.quotationItem.id ] );
			quotationItem = StructKeyExists( qiMap, json.quotationItem.id )
				? qiMap[ json.quotationItem.id ]
				: null;
		}

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
		);

		// Precarica tutti i QuotationItem in batch per evitare N+1
		var itemIds = [];
		for ( var row in rows ) {
			itemIds.append( row.quotation_item_id );
		}
		var itemMap = ArrayLen( itemIds ) ? getMany( itemIds ) : {};

		for ( var row in rows ) {
			var quotationItem = StructKeyExists( itemMap, row.quotation_item_id )
				? itemMap[ row.quotation_item_id ]
				: NullValue();
			if (
				IsNull( quotationItem ) ||
				( !IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemPlate") &&
				!IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemSignage") )
			) {
				continue;
			}

			aggiornaPrezzo(quotationItem);
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
		);

		// Precarica tutti i QuotationItem in batch per evitare N+1
		var itemIds = [];
		for ( var row in rows ) {
			itemIds.append( row.quotation_item_id );
		}
		var itemMap = ArrayLen( itemIds ) ? getMany( itemIds ) : {};

		for ( var row in rows ) {
			var quotationItem = StructKeyExists( itemMap, row.quotation_item_id )
				? itemMap[ row.quotation_item_id ]
				: NullValue();
			if (
				IsNull( quotationItem ) ||
				IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemPlate") ||
				IsInstanceOf(quotationItem, "com.apirone.core.model.bean.QuotationItemSignage") ||
				!isNull(quotationItem.getArticle())
			) {
				continue;
			}

			aggiornaPrezzo(quotationItem);
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
			var PLUG_IDS = [ "5f4ec169-c445-40a0-8c94-1dc22c21be79", "452e03e4-ddf4-4042-ac87-b0f17489c4e1" ];
			var realFruits = [];
			var positions = {};
			var fruits = quotationItem.getFruits();
			for (var fruit in fruits) {
				// escludi tappi esistenti: verranno ricalcolati
				if ( PLUG_IDS.find( LCase( fruit.getFruit().getId() ) ) ) continue;
				realFruits.append( fruit );
				var fruitItems = [];
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
				// costruisce json.positions per computePlugRuns
				var fruitPositions = fruit.getPositions();
				if ( !isNull( fruitPositions ) && ArrayLen( fruitPositions ) ) {
					var posArr = [];
					for ( var fp in fruitPositions ) {
						var posId = StructKeyExists( fp, "id" ) ? fp.id : ( StructKeyExists( fp, "position" ) ? fp.position : "" );
						if ( Len( posId ) ) posArr.append( { id: posId, order: fp.order } );
					}
					positions[ fruit.getId() ] = posArr;
				}
			}
			// fornisce frame.code e orientation a computePlugRuns
			json.positions = positions;
			json.item.product.frame = { "code": quotationItem.getProduct().getModel().getCode() };
			json.item.product.orientation = { "id": quotationItem.getFrame().getOrientation().getId() };
			// ricalcola i tappi e aggiorna la lista fruits
			var plugBeans = buildPlugFruitBeans( json );
			var allFruits = [];
			allFruits.append( realFruits, true );
			allFruits.append( plugBeans, true );
			quotationItem.setFruits( allFruits );
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
