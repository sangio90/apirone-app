
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
			if ( !StructKeyExists( position, 'id' ) && StructKeyExists( position, 'position' ) ) {
				position[ 'id' ] = position.position;
			}
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

		// Precarica i Product in batch con getMany() ottimizzato di ProductService
		var productMap = {};
		if ( ArrayLen( fruitIds ) ) {
			productMap = getProductService().getMany( fruitIds );
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
