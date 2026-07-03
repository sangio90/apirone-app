component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductItemDAO";
	property name="statusService" inject="StatusService";
	property name="attributeService" inject="AttributeService";
	property name="attributeValueService" inject="AttributeValueService";
	property name="rawValueService" inject="RawValueService";
	property name="FileService" inject="FileService";
	property name="componentService" inject="ComponentService";
	property name="priceService" inject="PriceService";
	property name="textService" inject="TextService";

	public com.apirone.core.model.bean.ProductItem function get( required productItemId ){
		return build( arguments.productItemId );
	}

	public Array function getTree( required String productId ){
		var result = [];

		var productId = arguments.productId;

		var baseItems = list( productId = arguments.productId );

		for ( var item in baseItems ) {
			var rows = getRecursiveTree( originId = item.getId(), rows = [] )
			item.setChildren( rows );

			result.add( item );
		}

		return result;
	}

	public Array function getFlatTree(
		required String productId,
		required Numeric originId             = NullValue(),
		required String level                 = 1,
		required String orderBy               = "",
		required Boolean includeMissingValues = true
	){
		var result = [];
		var rows   = [];

		var productId = arguments.productId;

		var items = list( productId = arguments.productId, originId = arguments.originId );

		if ( arguments.includeMissingValues ) {
			rows = listWithMissingValues( items );
		} else {
			rows = items;
		}

		var thisLevel            = arguments.level;
		var includeMissingValues = arguments.includeMissingValues;

		var n = 1;

		for ( var row in rows ) {
			var thisOrderBy = "#arguments.orderBy#.#n#";
			var originId    = row.getId();

			row.setLevel( arguments.level );

			result.add( row );

			var rows = getFlatTree(
				productId,
				originId,
				thisLevel + 1,
				thisOrderBy,
				includeMissingValues
			);

			result = result.merge( rows );

			n++;
		}

		return result;
	}


	public Array function list( String productId, Numeric originId ){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public Array function listComponents( required Numeric productItemId ){
		var result = getProductComponentService().list( productItemId = productItemId );

		return result;
	}

	public Boolean function addComponent(
		required Numeric productItemId,
		required com.apirone.core.model.bean.ProductComponent productComponent
	){
		transaction {
			getDao().deleteComponent( argumentCollection = arguments );
			getDao().insertComponent( argumentCollection = arguments );
		}

		return true;
	}

	public com.apirone.core.model.bean.Result function search( String productId, Numeric originId ){
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( record ){
			ids.append( record.product_item_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.product_item_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete(
		Numeric productItemId,
		String productId,
		String attributeId
	){
		if ( IsNull( arguments.productItemId ) && IsNull( arguments.productId ) && IsNull( arguments.attributeId ) ) {
			Throw( message = "At least one parameter is required to delete", type = "apirone.error.NoArgumentsPassed" );
		}

		var outcome = super.bean( "Outcome" );

		outcome.setData( arguments );

		transaction {
			try {
				getDao().delete( argumentCollection = arguments );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProductItem" );
				outcome.setMessage( "Cannot delete product items by [#SerializeJSON( arguments )#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.ProductItem productItem ){
		var newId = getDao().insert( arguments.productItem );

		return newId;
	}


	public String function update( required com.apirone.core.model.bean.ProductItem productItem ){
		var newId = getDao().update( arguments.productItem );

		return newId;
	}


	/*
    	private method
	*/

	private Void function printTree( required array items, numeric level = "0" ){
		for ( var item in arguments.items ) {
			var indent = RepeatString( "&nbsp;&nbsp;&nbsp;&nbsp;", arguments.level );

			//  Stampa il nome della categoria con l'indentazione
			Echo( "#indent# - #item.id# #item.attributeValue.texts[ 1 ].name# <br>" );

			//  Se la categoria ha dei figli, chiama ricorsivamente la funzione
			if ( StructKeyExists( item, "items" ) && ArrayLen( item.items ) > 0 ) {
				printTree( item.items, arguments.level + 1 );
			}
		}
	}

	private Array function getRecursiveTree( required Numeric originId ){
		var result = [];

		var items = list( originId = arguments.originId );

		for ( var item in items ) {
			var itemRows = getRecursiveTree( originId = item.getId() );

			if ( ArrayLen( itemRows ) ) {
				item.setChildren( itemRows );
			}

			ArrayAppend( result, item );
		}

		return result;
	}

	private Array function calcultateAttributes( required Array rows ){
		var attrs = [];

		Boolean function exists( required attributeId, required attrs ){
			for ( var attr in arguments.attrs ) {
				if ( attr.getId() == arguments.attributeId ) {
					return true;
				}
			}

			return false
		}

		for ( var row in rows ) {
			if ( !exists( row.getAttribute().getId(), attrs ) ) {
				// attribute with all values
				attrs.add( getAttributeService().get( row.getAttribute().getId() ) );
			}
		}

		return attrs;
	}

	private Array function listWithMissingValues( required Array productItems ){
		var values = [];

		var items = Duplicate( arguments.productItems );

		// 1. calcolo gli attributi dei valori recuperati
		var attrs = calcultateAttributes( arguments.productItems );

		for ( var thisAttr in attrs ) {
			for ( var thisValue in thisAttr.getValues() ) {
				// 2. cerco i valori mancanti per ogni attributo

				var found   = false;
				var index   = 1;
				var payload = { found = false, parent = NullValue() };

				for ( var thisProduct in arguments.productItems ) {
					payload.parent = thisProduct.getOrigin();

					if ( thisAttr.getId() == thisProduct.getAttribute().getId() ) {
						if (
							thisValue.getRawValue().getId() == thisProduct
								.getAttributeValue()
								.getRawValue()
								.getId()
						) {
							payload.found = true;
						}

						var lastOrderby   = thisProduct.getOrderBy();
						var lastAttribute = thisAttr;

						index++;
					}
				}

				if ( !payload.found ) {
					var bean = super.bean( "ProductItem" );

					bean.setId( -1 );
					bean.setAttributeValue( thisValue );
					bean.setAttribute( lastAttribute );
					bean.setStatus( getStatusService().get( "DEA" ) );
					bean.setOrigin( payload.parent );

					// attributeValue
					bean.setOrderBy( lastOrderby + 10 );

					items.insertAt( index, bean );
				}
			}
		}

		return items;
	}

	/**
	 * Recupera in batch più ProductItem dato un array di ID.
	 * Restituisce uno Struct chiave = productItemId, valore = bean ProductItem.
	 * precarica AttributeValue, Attribute, Price, File e Origin in batch
	 * per evitare il problema N+1 in buildFromRow().
	 *
	 * @ids Array di productItemId
	 * @return Struct mappato per productItemId -> ProductItem
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie gli ID delle FK
		var attributeValueIds = [];
		var originIds         = [];

		for ( var r in records ) {
			if ( !IsNull( r.attribute_raw_value_id ) ) {
				attributeValueIds.append( r.attribute_raw_value_id );
			}
			if ( !IsNull( r.origin_id ) ) {
				originIds.append( r.origin_id );
			}
		}

		// Precarica i File per attributeValue in batch (dichiarato prima, usato anche nel loop AV)
		var fileAttrMap  = ArrayLen( attributeValueIds )
			? getFileService().listByEntityIds( "attributeValue.id", attributeValueIds )
			: {};

		// Precarica gli AttributeValue in batch (1 query) e raccoglie gli attribute_id
		var attrValueMap = {};
		var allAttrIds   = [];
		if ( ArrayLen( attributeValueIds ) ) {
			var avRecords = getAttributeValueService().getDao().readByIds( attributeValueIds );

			// Raccoglie i raw_value_id per precaricamento batch dei RawValue
			var allRawValueIds = [];
			for ( var avr in avRecords ) {
				if ( !IsNull( avr.raw_value_id ) ) {
					allRawValueIds.append( avr.raw_value_id );
				}
			}

			// Batch-load dei RawValue via DAO
			var rawValueMap = {};
			if ( ArrayLen( allRawValueIds ) ) {
				var rvRecs = getRawValueService().getDao().readByIds( allRawValueIds );

				// Precarica i testi per i RawValue in batch
				var rawValueTextMap = getTextService().listByEntityIds( "rawValue.id", allRawValueIds );

				for ( var rvr in rvRecs ) {
					var rvBean = super.bean( "RawValue" );
					rvBean.setId( rvr.raw_value_id );
					rvBean.setCode( rvr.code );
					rvBean.setCreatedAt( rvr.created_at );
					// Testi: dalla mappa pre-caricata
					if ( StructKeyExists( rawValueTextMap, rvr.raw_value_id ) ) {
						rvBean.setTexts( rawValueTextMap[ rvr.raw_value_id ] );
					}
					rawValueMap[ rvr.raw_value_id ] = rvBean;
				}
			}

			for ( var avr in avRecords ) {
				var avBean = super.bean( "AttributeValue" );
				avBean.setId( avr.attribute_raw_value_id );
				avBean.setAttributeId( avr.attribute_id.toString() );
				avBean.setCreatedAt( avr.created_at );
				avBean.setOrderBy( avr.orderby );
				avBean.setAllowNote( avr.allow_note ? true : false );
				avBean.setAffectToImage( avr.affect_to_image ? true : false );
				avBean.setComponentCount( avr.component_count );
				avBean.setStatus( getStatusService().get( avr.status_id ) );
				// RawValue: dalla mappa pre-caricata
				if ( !IsNull( avr.raw_value_id ) && StructKeyExists( rawValueMap, avr.raw_value_id ) ) {
					avBean.setRawValue( rawValueMap[ avr.raw_value_id ] );
				}
				attrValueMap[ avr.attribute_raw_value_id ] = avBean;
				// Images: dalla mappa pre-caricata
				if ( StructKeyExists( fileAttrMap, avr.attribute_raw_value_id ) && Len( fileAttrMap[ avr.attribute_raw_value_id ] ) ) {
					avBean.setImages( fileAttrMap[ avr.attribute_raw_value_id ] );
				}
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

		// Precarica i File in batch per productItem
		var fileMap = getFileService().listByEntityIds( "productItem.id", arguments.ids );

		// Precarica i Prezzi in batch (1 query, nuovo metodo DAO)
		var priceMap = {};
		if ( ArrayLen( arguments.ids ) ) {
			var priceRecords = getPriceService().getDao().findByProductItemIds( arguments.ids );
			for ( var pr in priceRecords ) {
				if ( !StructKeyExists( priceMap, pr.product_item_id ) ) {
					priceMap[ pr.product_item_id ] = [];
				}
				// buildFromRow è public su PriceService
				priceMap[ pr.product_item_id ].append( getPriceService().buildFromRow( pr ) );
			}
		}

		// Precarica gli Origin in batch con getMany() ottimizzato (1 livello di ricorsione)
		var originMap = ArrayLen( originIds ) ? getMany( originIds ) : {};

		// Costruisce i bean ProductItem con le mappe pre-caricate
		for ( var r in records ) {
			var bean = super.bean( "ProductItem" );

			// Campi diretti dal record
			bean.setId( r.product_item_id );
			bean.setProductId( r.product_id );
			bean.setCreatedAt( r.created_at );
			bean.setImportant( r.important );
			bean.setOrderBy( r.orderby );

			// Status (cached)
			bean.setStatus( getStatusService().get( r.status_id ) );

			// Origin: dalla mappa pre-caricata
			if ( !IsNull( r.origin_id ) && StructKeyExists( originMap, r.origin_id ) ) {
				bean.setOrigin( originMap[ r.origin_id ] );
			} else if ( !IsNull( r.origin_id ) ) {
				// Fallback: chiamata individuale (caso raro)
				bean.setOrigin( get( r.origin_id ) );
			}

			// AttributeValue + Attribute: dalle mappe pre-caricate
			if ( !IsNull( r.attribute_raw_value_id ) && StructKeyExists( attrValueMap, r.attribute_raw_value_id ) ) {
				bean.setAttributeValue( attrValueMap[ r.attribute_raw_value_id ] );
				var av = attrValueMap[ r.attribute_raw_value_id ];
				if ( StructKeyExists( attrMap, av.getAttributeId() ) ) {
					bean.setAttribute( attrMap[ av.getAttributeId() ] );
				}
			}

			bean.setComponentCount( 0 );
			bean.setChildren( [] );

			// Prezzi: dalla mappa pre-caricata (sempre un array, anche se vuoto)
			bean.setPrices(
				StructKeyExists( priceMap, r.product_item_id ) ? priceMap[ r.product_item_id ] : []
			);

			// Immagini: prima per productItemId, fallback per attributeValueId
			if ( StructKeyExists( fileMap, r.product_item_id ) && Len( fileMap[ r.product_item_id ] ) ) {
				bean.setImages( fileMap[ r.product_item_id ] );
			} else if ( !IsNull( r.attribute_raw_value_id ) && StructKeyExists( fileAttrMap, r.attribute_raw_value_id ) && Len( fileAttrMap[ r.attribute_raw_value_id ] ) ) {
				bean.setImages( fileAttrMap[ r.attribute_raw_value_id ] );
			}

			map[ r.product_item_id ] = bean;
		}

		return map;
	}

	private com.apirone.core.model.bean.ProductItem function build( required String productItemId ){
		var record = getDao().read( arguments.productItemId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean ProductItem a partire da una riga della query, senza chiamata DB aggiuntiva
	 * per il record principale.
	 */
	public com.apirone.core.model.bean.ProductItem function buildFromRow( required any record ){
		var bean = super.bean( "ProductItem" );

		// Campi diretti dal record
		bean.setId( record.product_item_id );
		bean.setProductId( record.product_id );
		bean.setCreatedAt( record.created_at );
		bean.setImportant( record.important );
		bean.setOrderBy( record.orderby );

		// Entity collegate (caricate singolarmente)
		bean.setOrigin( IsNull( record.origin_id ) ? NullValue() : get( record.origin_id ) );
		bean.setStatus( getStatusService().get( record.status_id ) );

		var attributeValue = getAttributeValueService().get( record.attribute_raw_value_id );
		bean.setAttributeValue( attributeValue );
		bean.setAttribute( getAttributeService().get( attributeValue.getAttributeId() ) );
		bean.setComponentCount( 0 );

		bean.setChildren( [] );

		bean.setPrices( getPriceService().list( productItemId = record.product_item_id ) );

		var images = getFileService().list( productItemId = record.product_item_id );

		if ( Len( images ) ) {
			bean.setImages( images );
		} else {
			var images = getFileService().list( attributeValueId = record.attribute_raw_value_id );
			if ( Len( images ) ) {
				bean.setImages( images );
			}
		}

		return bean;
	}

	/**
	 * Recupera in batch tutti i ProductItem collegati a una lista di productId.
	 * Restituisce uno Struct chiave = productId, valore = Array di bean ProductItem.
	 * Sostituisce chiamate ripetute a list() per ogni prodotto.
	 *
	 * @productIds Array di productId
	 * @return Struct mappato per productId -> Array di ProductItem
	 */
	public Struct function listByProductIds( required Array productIds ){
		var records = getDao().findByProductIds( productIds = arguments.productIds );
		var map     = {};

		// Raccoglie tutti gli ID per un unico precaricamento batch
		var ids = [];
		for ( var record in records ) {
			ids.append( record.product_item_id );
		}

		// Precarica tutti i ProductItem in una sola passata con getMany()
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Raggruppa i bean per productId
		for ( var record in records ) {
			var productId = record.product_id;
			if ( !StructKeyExists( map, productId ) ) {
				map[ productId ] = [];
			}
			ArrayAppend( map[ productId ], beanMap[ record.product_item_id ] );
		}

		return map;
	}

}
