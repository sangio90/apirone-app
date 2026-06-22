component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemProductDAO";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="ProductService" inject="ProductService";
	property name="QuotationItemProductService" inject="QuotationItemProductService";

	public com.apirone.core.model.bean.QuotationItemProduct function get( required String productId ){
		return build( arguments.productId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationItemProduct.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();

		// Il find() restituisce già le FK: si possono costruire i bean direttamente
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID per il caricamento batch
		var ids = [];
		records.each( function( record ){
			ids.append( record.quotation_item_product_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.quotation_item_product_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.productId );

		outcome.setData( { productId = arguments.productId } );

		transaction {
			try {
				getDao().delete( arguments.productId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItemProduct" );
				outcome.setMessage( "Cannot delete product [#arguments.productId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemProduct product ){
		var newId = getDao().insert( arguments.product );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemProduct product ){
		getDao().update( arguments.product );

		return arguments.product.getId();
	}

	/**
	 * Recupera in batch più QuotationItemProduct dato un array di ID.
	 * Restituisce uno Struct chiave = quotationItemProductId, valore = bean QuotationItemProduct.
	 * Precarica product, quotationItem e origin in batch per evitare il problema N+1.
	 *
	 * @ids Array di quotationItemProductId
	 * @return Struct mappato per quotationItemProductId -> QuotationItemProduct
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie gli ID unici di product, quotationItem e origin da tutti i record
		var productIds       = [];
		var quotationItemIds = [];
		var originIds        = [];
		for ( var record in records ) {
			if ( !IsNull( record.product_id ) ) {
				productIds.append( record.product_id );
			}
			if ( !IsNull( record.quotation_item_id ) ) {
				quotationItemIds.append( record.quotation_item_id );
			}
			if ( !IsNull( record.origin_id ) ) {
				originIds.append( record.origin_id );
			}
		}

		// Precarica i Product in batch: ProductService non ha getMany() pubblico (usa buildMany interno).
		// Usiamo ProductDAO.readByIds e costruiamo bean minimali.
		var productMap = {};
		if ( ArrayLen( productIds ) ) {
			var uniqueProductIds = [];
			for ( var pid in productIds ) {
				if ( !IsNull( pid ) && !ArrayContains( uniqueProductIds, pid ) ) {
					uniqueProductIds.append( pid );
				}
			}
			if ( ArrayLen( uniqueProductIds ) ) {
				var prodRecords = getProductService().getDao().readByIds( uniqueProductIds );
				for ( var pr in prodRecords ) {
					var prodBean = super.bean( "Product" );
					prodBean.setId( pr.product_id.toString() );
					prodBean.setSerial( pr.serial );
					prodBean.setCreatedAt( pr.created_at );
					prodBean.setMinQuantity( pr.min_quantity );
					prodBean.setMaxQuantity( pr.max_quantity );
					prodMap[ pr.product_id.toString() ] = prodBean;
				}
			}
		}

		// Precarica i QuotationItem in batch: QuotationItemService non ha getMany(), è pesante.
		// Carichiamo solo i campi base per evitare cascate N+1 profonde.
		var quotationItemMap = {};
		if ( ArrayLen( quotationItemIds ) ) {
			var uniqueQiIds = [];
			for ( var qid in quotationItemIds ) {
				if ( !IsNull( qid ) && !ArrayContains( uniqueQiIds, qid ) ) {
					uniqueQiIds.append( qid );
				}
			}
			if ( ArrayLen( uniqueQiIds ) ) {
				var qiRecords = getQuotationItemService().getDao().readByIds( uniqueQiIds );
				for ( var qr in qiRecords ) {
					var qiBean = super.bean( "QuotationItem" );
					qiBean.setId( qr.quotation_item_id );
					qiBean.setQuantity( qr.quantity );
					qiBean.setPrice( qr.price );
					qiBean.setTotal( qr.total );
					qiBean.setCreatedAt( qr.created_at );
					// Sub-entity pesanti non precaricate in batch
					quotationItemMap[ qr.quotation_item_id ] = qiBean;
				}
			}
		}

		// Per gli origin, raccogliamo anche quelli (sono QuotationItemProduct a loro volta)
		var originMap = {};
		if ( ArrayLen( originIds ) ) {
			var uniqueOriginIds = [];
			for ( var oid in originIds ) {
				if ( !IsNull( oid ) && !ArrayContains( uniqueOriginIds, oid ) ) {
					uniqueOriginIds.append( oid );
				}
			}
			if ( ArrayLen( uniqueOriginIds ) ) {
				var origRecords = getDao().readByIds( uniqueOriginIds );
				for ( var or_rec in origRecords ) {
					var oBean = super.bean( "QuotationItemProduct" );
					oBean.setId( or_rec.quotation_item_product_id );
					// Product e QuotationItem non precaricati per gli origin (evita ricorsione)
					originMap[ or_rec.quotation_item_product_id ] = oBean;
				}
			}
		}

		for ( var record in records ) {
			var bean = super.bean( "QuotationItemProduct" );

			// Campi diretti dal record
			bean.setId( record.quotation_item_product_id );

			// QuotationItem: dalla mappa pre-caricata
			if ( !IsNull( record.quotation_item_id ) && StructKeyExists( quotationItemMap, record.quotation_item_id ) ) {
				bean.setQuotationItem( quotationItemMap[ record.quotation_item_id ] );
			}

			// Product: dalla mappa pre-caricata
			if ( !IsNull( record.product_id ) && StructKeyExists( productMap, record.product_id.toString() ) ) {
				bean.setProduct( productMap[ record.product_id.toString() ] );
			}

			// Origin (condizionale): dalla mappa pre-caricata
			if ( !IsNull( record.origin_id ) && StructKeyExists( originMap, record.origin_id ) ) {
				bean.setOrigin( originMap[ record.origin_id ] );
			} else if ( !IsNull( record.origin_id ) ) {
				bean.setOrigin( NullValue() );
			}

			map[ record.quotation_item_product_id ] = bean;
		}

		return map;
	}

	/**
	 * Costruisce un bean QuotationItemProduct a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.QuotationItemProduct function build( required String productId ){
		var record = getDao().read( arguments.productId );
		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}
		return NullValue();
	}

	/**
	 * Costruisce un bean QuotationItemProduct a partire da una riga della query.
	 * Le sub-entity (QuotationItem, Product, origin) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.QuotationItemProduct function buildFromFindRow( required any record ){
		var bean = super.bean( "QuotationItemProduct" );

		// Campi diretti dal record
		bean.setId( record.quotation_item_product_id );

		// Entity collegate (caricate singolarmente)
		bean.setQuotationItem( getQuotationItemService().get( record.quotation_item_id ) );
		bean.setProduct( getProductService().get( record.product_id ) );

		bean.setOrigin(
			IsNull( record.origin_id ) ? NullValue() : getQuotationItemProductService().get( record.origin_id )
		);

		return bean;
	}

}
