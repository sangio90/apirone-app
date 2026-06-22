
component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemFruitDAO";
	property name="productService" inject="ProductService";
	property name="quotationItemProductItemService" inject="QuotationItemProductItemService";
	property name="quotationItemFruitPositionService" inject="QuotationItemFruitPositionService";
	property name="productItemService" inject="ProductItemService";
	property name="CatalogBundleService" inject="CatalogBundleService";
	property name="statusService" inject="StatusService";
	property name="textService" inject="TextService";
	property name="priceService" inject="PriceService";
	property name="fileService" inject="FileService";
	property name="finishService" inject="FinishService";
	property name="productCategoryService" inject="ProductCategoryService";

	public com.apirone.core.model.bean.QuotationItemFruit function get( required Numeric quotationItemFruitId ){
		return build( arguments.quotationItemFruitId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationItemFruit.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		if ( records.recordCount ) {
			// Raccoglie tutti gli ID e carica i record in blocco con una sola query
			var ids = [];
			for ( var record in records ) {
				ids.append( record.quotation_item_fruit_id );
			}

			// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
			var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				if ( StructKeyExists( beanMap, record.quotation_item_fruit_id ) ) {
					rows.add( beanMap[ record.quotation_item_fruit_id ] );
				}
			}
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric quotationItemFruitId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemFruitId = arguments.quotationItemFruitId } );

		transaction {
			try {
				getDao().delete( arguments.quotationItemFruitId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteQuotationItemFruit" );
				outcome.setMessage( "Cannot delete quotation item fruit [#arguments.quotationItemFruitId#]" );
			}
		}

		return outcome;
	}

	public Numeric function create( required com.apirone.core.model.bean.QuotationItemFruit quotationItemFruit ){
		var newId = getDao().insert( arguments.quotationItemFruit );

		// 01 items
		if( !IsNull( arguments.quotationItemFruit.getItems() ) ){
			for( var item in arguments.quotationItemFruit.getItems() ){
				item.setQuotationItemFruitId( newId );
				getQuotationItemProductItemService().create( item );
			}
		}

		// 02 positions
		for( var position in arguments.quotationItemFruit?.getPositions() ){
			getQuotationItemFruitPositionService().create( newId, position.id, position.order );
		}

		return newId;
	}

	public Numeric function update( required com.apirone.core.model.bean.QuotationItemFruit quotationItemFruit ){
		getDao().update( arguments.quotationItemFruit );

		cffile( action="append", file="#ExpandPath('/debug.log')#", output="update quotationItemFruit: #arguments.quotationItemFruit.getId()#" );

		// 01 items
		getQuotationItemProductItemService().deleteByQuotationItemFruitId( arguments.quotationItemFruit.getId() );

		if( !IsNull( arguments.quotationItemFruit.getItems() ) ){
			for( var item in arguments.quotationItemFruit?.getItems() ){
				item.setQuotationItemFruitId( arguments.quotationItemFruit.getId() );
				getQuotationItemProductItemService().create( item );
			}
		}

		// 02 positions
		getQuotationItemFruitPositionService().deleteByQuotationItemFruitId( arguments.quotationItemFruit.getId() );
		cffile( action="append", file="#ExpandPath('/debug.log')#", output="delete positions: #arguments.quotationItemFruit.getId()#, #SerializeJSON(arguments.quotationItemFruit.getPositions())#" );

		for( var position in arguments.quotationItemFruit?.getPositions() ){
			if (!StructKeyExists(position, 'id') && StructKeyExists(position, 'position')) {
				position['id'] = position.position;
			}
			getQuotationItemFruitPositionService().create( arguments.quotationItemFruit.getId(), position.id, position.order );
		}

		return arguments.quotationItemFruit.getId();
	}


	/*
		private methods
	*/

	/*
		private methods
	*/

	/**
	 * Recupera in batch più QuotationItemFruit dato un array di ID.
	 * Restituisce uno Struct chiave = quotationItemFruitId, valore = bean QuotationItemFruit.
	 * Precarica Product, ProductItem e FruitPosition in batch per evitare il problema N+1.
	 *
	 * @ids Array di quotationItemFruitId
	 * @return Struct mappato per quotationItemFruitId -> QuotationItemFruit
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie tutti i fruit_id per precaricare i Product in batch
		var fruitIds = [];
		for ( var record in records ) {
			if ( !IsNull( record.fruit_id ) ) {
				fruitIds.append( record.fruit_id );
			}
		}

		// Precarica i Product in batch (via readByIds del DAO, senza getMany pubblico)
		var productMap = {};
		if ( ArrayLen( fruitIds ) ) {
			var productRecords = getProductService().getDao().readByIds( fruitIds );

			// Raccoglie i catalog_bundle_id per i ProductComplex
			var bundleIds = [];
			for ( var pr in productRecords ) {
				if ( !IsNull( pr.catalog_bundle_id ) ) {
					bundleIds.append( pr.catalog_bundle_id );
				}
			}

			// Precarica i CatalogBundle in batch
			var bundleMap = {};
			if ( ArrayLen( bundleIds ) ) {
				bundleMap = getCatalogBundleService().getMany( bundleIds );
			}

			// Precarica i testi dei prodotti in batch
			var productTextMap = getTextService().listByEntityIds( "product.id", fruitIds );

			// Precarica i prezzi dei prodotti in batch
			var productPriceMap = getPriceService().listByProductIds( fruitIds );

			// Precarica le immagini dei prodotti in batch
			var productFileMap = getFileService().listByEntityIds( "product.id", fruitIds );

			// Raccoglie i finish_id per i ProductComplex e i product_category_id per i ProductBase
			var finishIds           = [];
			var productCategoryIds  = [];
			for ( var pr in productRecords ) {
				if ( !IsNull( pr.finish_id ) ) {
					finishIds.append( pr.finish_id );
				}
				if ( !IsNull( pr.product_category_id ) ) {
					productCategoryIds.append( pr.product_category_id );
				}
			}

			// Precarica le Finish in batch
			var finishMap = {};
			if ( ArrayLen( finishIds ) ) {
				finishMap = getFinishService().getMany( finishIds );
			}

			// Precarica le ProductCategory in batch
			var categoryMap = {};
			if ( ArrayLen( productCategoryIds ) ) {
				categoryMap = getProductCategoryService().getMany( productCategoryIds );
			}

			for ( var pr in productRecords ) {
				if ( IsNull( pr.catalog_bundle_id ) ) {
					var productBean = super.bean( "ProductBase" );
					productBean.setCode( pr.code );
					productBean.setPositionCount( pr.position_count );
					// Categoria per ProductBase
					if ( !IsNull( pr.product_category_id ) && StructKeyExists( categoryMap, pr.product_category_id ) ) {
						productBean.setCategory( categoryMap[ pr.product_category_id ] );
					}
					// Lines per ProductBase
					if ( Len( pr.lines ) ) {
						productBean.setLines( super.getLinesBeanByIds( pr.lines ) );
					}
				} else {
					var productBean = super.bean( "ProductComplex" );
					if ( StructKeyExists( bundleMap, pr.catalog_bundle_id ) ) {
						productBean.setCatalogBundle( bundleMap[ pr.catalog_bundle_id ] );
						var bundle = bundleMap[ pr.catalog_bundle_id ];
						productBean.setLine( bundle.getLine() );
						productBean.setModel( bundle.getModel() );
						productBean.setCategory( bundle.getCategory() );
					}
					// Finish per ProductComplex
					if ( !IsNull( pr.finish_id ) && StructKeyExists( finishMap, pr.finish_id ) ) {
						productBean.setFinish( finishMap[ pr.finish_id ] );
					}
				}

				// Campi comuni
				productBean.setId( pr.product_id.toString() );
				productBean.setCreatedAt( pr.created_at );
				productBean.setSerial( pr.serial );
				productBean.setSpecial( BooleanFormat( pr.special ) );
				productBean.setMinQuantity( pr.min_quantity );
				productBean.setMaxQuantity( pr.max_quantity );
				productBean.setMarginTop( pr.margin_top );
				productBean.setMarginLeft( pr.margin_left );
				productBean.setPlateWidth( pr.plate_width );
				productBean.setPlateHeight( pr.plate_height );
				productBean.setStatus( getStatusService().get( pr.status_id ) );

				// Testi: dalla mappa pre-caricata
				if ( StructKeyExists( productTextMap, pr.product_id ) ) {
					productBean.setTexts( productTextMap[ pr.product_id ] );
				}

				// Prezzi: dalla mappa pre-caricata
				if ( StructKeyExists( productPriceMap, pr.product_id ) ) {
					productBean.setPrices( productPriceMap[ pr.product_id ] );
				}

				// Immagini: dalla mappa pre-caricata
				if ( StructKeyExists( productFileMap, pr.product_id ) && Len( productFileMap[ pr.product_id ] ) ) {
					productBean.setImages( productFileMap[ pr.product_id ] );
				}

				// Attributi importanti
				if ( Len( pr.attributes_important ) ) {
					productBean.setImportantAttributes( super.getAttributesBeanByIds( pr.attributes_important ) );
				}

				productMap[ pr.product_id ] = productBean;
			}
		}

		// Precarica i ProductItem in batch per tutti i quotation_item_fruit_id
		var itemMap = {};
		var allProductItemIds = [];
		if ( ArrayLen( arguments.ids ) ) {
			var idsList = ArrayToList( arguments.ids );
			var itemRecords = QueryExecute(
				"SELECT * FROM quotation_item_product_items WHERE quotation_item_fruit_id IN ( :ids )",
				{ ids: { value: idsList, list: true, cfsqltype: "integer" } },
				{ datasource: "apirone" }
			);
			for ( var ir in itemRecords ) {
				var fruitId = ir.quotation_item_fruit_id;
				if ( !StructKeyExists( itemMap, fruitId ) ) {
					itemMap[ fruitId ] = [];
				}
				if ( !IsNull( ir.product_item_id ) ) {
					allProductItemIds.append( ir.product_item_id );
				}
				var itemBean = super.bean( "QuotationItemProductItem" );
				itemBean.setId( ir.quotation_item_product_item_id );
				itemBean.setQuotationItemId( ir.quotation_item_id );
				itemBean.setLevel( ir.level );
				itemBean.setNote( ir.note );
				// product_item_id salvato temporaneamente per il lookup batch
				itemBean._productItemId = ir.product_item_id;
				ArrayAppend( itemMap[ fruitId ], itemBean );
			}
		}

		// Precarica i ProductItem in batch (1 query) e collega ai QIPI bean
		if ( ArrayLen( allProductItemIds ) ) {
			var uniquePiIds = [];
			for ( var pid in allProductItemIds ) {
				if ( !IsNull( pid ) && !ArrayContains( uniquePiIds, pid ) ) {
					uniquePiIds.append( pid );
				}
			}
			// Precarica tutti i ProductItem (main e origin) con getMany() ottimizzato
			var piMap = ArrayLen( uniquePiIds ) ? getProductItemService().getMany( uniquePiIds ) : {};

			// Collega i ProductItem ai beans QuotationItemProductItem
			for ( var fid in itemMap ) {
				for ( var itemBean in itemMap[ fid ] ) {
					if ( StructKeyExists( itemBean, "_productItemId" ) && StructKeyExists( piMap, itemBean._productItemId ) ) {
						itemBean.setProductItem( piMap[ itemBean._productItemId ] );
					}
					StructDelete( itemBean, "_productItemId" );
				}
			}
		}

		// Precarica le FruitPosition in batch per tutti i quotation_item_fruit_id
		var positionMap = {};
		if ( ArrayLen( arguments.ids ) ) {
			var idsList = ArrayToList( arguments.ids );
			var posRecords = QueryExecute(
				"SELECT * FROM quotation_item_fruit_positions WHERE quotation_item_fruit_id IN ( :ids ) ORDER BY quotation_item_fruit_id, ""order""",
				{ ids: { value: idsList, list: true, cfsqltype: "integer" } },
				{ datasource: "apirone" }
			);
			for ( var posr in posRecords ) {
				var fruitId = posr.quotation_item_fruit_id;
				if ( !StructKeyExists( positionMap, fruitId ) ) {
					positionMap[ fruitId ] = [];
				}
				ArrayAppend( positionMap[ fruitId ], {
					'position' = posr.position,
					'order'    = posr.order
				} );
			}
		}

		// Costruisce i bean con le mappe pre-caricate
		for ( var record in records ) {
			var bean = super.bean( "QuotationItemFruit" );

			// Campi diretti dal record
			bean.setId( record.quotation_item_fruit_id );
			bean.setCreatedAt( record.created_at );
			bean.setNote( record.note );

			// Product: dalla mappa pre-caricata
			if ( StructKeyExists( productMap, record.fruit_id ) ) {
				bean.setFruit( productMap[ record.fruit_id ] );
			}

			// Items: dalla mappa pre-caricata
			if ( StructKeyExists( itemMap, record.quotation_item_fruit_id ) && ArrayLen( itemMap[ record.quotation_item_fruit_id ] ) ) {
				bean.setItems( itemMap[ record.quotation_item_fruit_id ] );
			}

			// Positions: dalla mappa pre-caricata
			if ( StructKeyExists( positionMap, record.quotation_item_fruit_id ) && ArrayLen( positionMap[ record.quotation_item_fruit_id ] ) ) {
				bean.setPositions( positionMap[ record.quotation_item_fruit_id ] );
			}

			map[ record.quotation_item_fruit_id ] = bean;
		}

		return map;
	}

	/**
	 * Costruisce un Product bean semplificato dal record, determinando il tipo
	 * (ProductBase o ProductComplex) in base alla presenza di catalog_bundle_id.
	 */
	private com.apirone.core.model.bean.Product function resolveProductType( required any pr ){
		if ( IsNull( pr.catalog_bundle_id ) ) {
			var bean = super.bean( "ProductBase" );
			bean.setCode( pr.code );
			bean.setPositionCount( pr.position_count );
		} else {
			var bean = super.bean( "ProductComplex" );
		}

		// Campi comuni
		bean.setId( pr.product_id.toString() );
		bean.setSerial( pr.serial );
		bean.setCreatedAt( pr.created_at );
		bean.setSpecial( BooleanFormat( pr.special ) );
		bean.setMinQuantity( pr.min_quantity );
		bean.setMaxQuantity( pr.max_quantity );
		bean.setMarginTop( pr.margin_top );
		bean.setMarginLeft( pr.margin_left );
		bean.setPlateWidth( pr.plate_width );
		bean.setPlateHeight( pr.plate_height );

		return bean;
	}

	private com.apirone.core.model.bean.QuotationItemFruit function buildFromRow( required any record ){
		var bean = super.bean( "QuotationItemFruit" );

		// Campi diretti dal record
		bean.setId( record.quotation_item_fruit_id );
		bean.setCreatedAt( record.created_at );
		bean.setNote( record.note );

		// Entity collegate (caricate singolarmente)
		bean.setFruit( getProductService().get( record.fruit_id ) );

		var items = getQuotationItemProductItemService().list( quotationItemFruitId = record.quotation_item_fruit_id );

		if ( Len( items ) ) {
			bean.setItems( items );
		}

		var positions = getQuotationItemFruitPositionService().list( quotationItemFruitId = record.quotation_item_fruit_id );

		if ( Len( positions ) ) {
			bean.setPositions( positions );
		}

		return bean;
	}

	private com.apirone.core.model.bean.QuotationItemFruit function build( required Numeric quotationItemFruitId ){
		var record = getDao().read( arguments.quotationItemFruitId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

}
