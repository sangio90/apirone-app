component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemProductItemDAO";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="ProductItemService" inject="ProductItemService";
	property name="statusService" inject="StatusService";
	property name="attributeService" inject="AttributeService";
	property name="attributeValueService" inject="AttributeValueService";

	public com.apirone.core.model.bean.QuotationItemProductItem function get( required String productItemId ){
		return build( arguments.productItemId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotationItemProductItem.id" } ]
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
				ids.append( record.quotation_item_product_item_id );
			}

			// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
			var beanMap = getMany( ids );

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				if ( StructKeyExists( beanMap, record.quotation_item_product_item_id ) ) {
					rows.add( beanMap[ record.quotation_item_product_item_id ] );
				}
			}
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productItemId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.productItemId );

		outcome.setData( { productItemId = arguments.productItemId } );

		transaction {
			try {
				getDao().delete( arguments.productItemId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItemProductItem" );
				outcome.setMessage( "Cannot delete product item [#arguments.productItemId#]" );
			}
		}

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByQuotationItemFruitId( required String quotationItemFruitId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemFruitId = arguments.quotationItemFruitId } );

		transaction {
			try {
				getDao().deleteByQuotationItemFruitId( arguments.quotationItemFruitId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationItemProductItem" );
				outcome.setMessage( "Cannot delete product item by quotation item fruit id: [#arguments.quotationItemFruitId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationItemProductItem productItem ){
		var newId = getDao().insert( arguments.productItem );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationItemProductItem productItem ){
		getDao().update( arguments.productItem );

		return arguments.productItem.getId();
	}

	/**
	 * Recupera in batch più QuotationItemProductItem dato un array di ID.
	 * Restituisce uno Struct chiave = quotationItemProductItemId, valore = bean QuotationItemProductItem.
	 * Precarica i productItem (e gli origin) in batch per evitare il problema N+1.
	 *
	 * @ids Array di quotationItemProductItemId
	 * @return Struct mappato per quotationItemProductItemId -> QuotationItemProductItem
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie tutti gli ID unici di productItem (sia diretti che origin)
		var allProductItemIds = [];
		for ( var record in records ) {
			if ( !IsNull( record.product_item_id ) ) {
				allProductItemIds.append( record.product_item_id );
			}
			if ( !IsNull( record.origin_id ) ) {
				allProductItemIds.append( record.origin_id );
			}
		}

		// Precarica i ProductItem in batch: ProductItemService non ha getMany(), usa DAO
		var productItemMap = {};
		if ( ArrayLen( allProductItemIds ) ) {
			var uniquePiIds = [];
			for ( var pid in allProductItemIds ) {
				if ( !IsNull( pid ) && !ArrayContains( uniquePiIds, pid ) ) {
					uniquePiIds.append( pid );
				}
			}
			if ( ArrayLen( uniquePiIds ) ) {
				var piRecords = getProductItemService().getDao().readByIds( uniquePiIds );

				// Raccoglie gli attribute_raw_value_id per il precaricamento batch
				var allAttrValueIds = [];
				for ( var pir in piRecords ) {
					if ( !IsNull( pir.attribute_raw_value_id ) ) {
						allAttrValueIds.append( pir.attribute_raw_value_id );
					}
				}

				// Precarica gli AttributeValue in batch (1 query)
				var attrValueMap = {};
				var allAttrIds = [];
				if ( ArrayLen( allAttrValueIds ) ) {
					var avRecords = getAttributeValueService().getDao().readByIds( allAttrValueIds );
					for ( var avr in avRecords ) {
						var avBean = super.bean( "AttributeValue" );
						avBean.setId( avr.attribute_raw_value_id );
						avBean.setAttributeId( avr.attribute_id.toString() );
						avBean.setCreatedAt( avr.created_at );
						avBean.setOrderBy( avr.orderby );
						avBean.setStatus( getStatusService().get( avr.status_id ) );
						attrValueMap[ avr.attribute_raw_value_id ] = avBean;
						if ( !IsNull( avr.attribute_id ) ) {
							allAttrIds.append( avr.attribute_id );
						}
					}
				}

				// Precarica gli Attribute in batch (1 query, getMany() è già ottimizzato)
				var attrMap = {};
				if ( ArrayLen( allAttrIds ) ) {
					attrMap = getAttributeService().getMany( allAttrIds );
				}

				for ( var pir in piRecords ) {
					var piBean = super.bean( "ProductItem" );
					piBean.setId( pir.product_item_id );
					piBean.setProductId( pir.product_id );
					piBean.setCreatedAt( pir.created_at );
					piBean.setImportant( pir.important );
					piBean.setOrderBy( pir.orderby );
					// Status: cached localmente
					piBean.setStatus( getStatusService().get( pir.status_id ) );

					// AttributeValue: dalla mappa pre-caricata
					if ( !IsNull( pir.attribute_raw_value_id ) && StructKeyExists( attrValueMap, pir.attribute_raw_value_id ) ) {
						piBean.setAttributeValue( attrValueMap[ pir.attribute_raw_value_id ] );
						// Attribute: derivato dall'AttributeValue, dalla mappa pre-caricata
						var av = attrValueMap[ pir.attribute_raw_value_id ];
						if ( StructKeyExists( attrMap, av.getAttributeId() ) ) {
							piBean.setAttribute( attrMap[ av.getAttributeId() ] );
						}
					}

					piBean.setOrigin( NullValue() );
					piBean.setChildren( [] );
					productItemMap[ pir.product_item_id ] = piBean;
				}
			}
		}

		for ( var record in records ) {
			var bean = super.bean( "QuotationItemProductItem" );

			// Campi diretti dal record
			bean.setId( record.quotation_item_product_item_id );
			bean.setQuotationItemId( record.quotation_item_id );
			bean.setLevel( record.level );
			bean.setNote( record.note );

			// ProductItem: dalla mappa pre-caricata
			if ( !IsNull( record.product_item_id ) && StructKeyExists( productItemMap, record.product_item_id ) ) {
				bean.setProductItem( productItemMap[ record.product_item_id ] );
			}

			// Origin (condizionale): dalla mappa pre-caricata
			if ( !IsNull( record.origin_id ) && StructKeyExists( productItemMap, record.origin_id ) ) {
				bean.setOrigin( productItemMap[ record.origin_id ] );
			}

			map[ record.quotation_item_product_item_id ] = bean;
		}

		return map;
	}

	private com.apirone.core.model.bean.QuotationItemProductItem function buildFromRow( required any record ){
		var bean = super.bean( "QuotationItemProductItem" );
		
		// Campi diretti dal record
		bean.setId( record.quotation_item_product_item_id );
		bean.setQuotationItemId( record.quotation_item_id );
		bean.setLevel( record.level );
		bean.setNote( record.note );

		// Entity collegate (caricate singolarmente)
		bean.setProductItem( getProductItemService().get( record.product_item_id ) );

		if ( !IsNull( record.origin_id ) ) {
			bean.setOrigin( getProductItemService().get( record.origin_id ) );
		}

		return bean;
	}

	private com.apirone.core.model.bean.QuotationItemProductItem function build( required String productItemId ){
		var record = getDao().read( arguments.productItemId );
		if ( record.recordCount ) {
			return buildFromRow( record );
		}
		return NullValue();
	}

}
