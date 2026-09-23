component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductHashDAO";
	property name="ProductItemService" inject="ProductItemService";
	property name="QuotationItemService" inject="QuotationItemService";

	public com.apirone.core.model.bean.ProductHash function get( required Numeric productHashId ){
		return build( arguments.productHashId );
	}

	public com.apirone.core.model.bean.ProductHash function getByHash( required String hash ){
		var record = getDao().find( argumentCollection = arguments );

		if (Len(record)) {
			var bean = build( record.product_hash_id );

			return bean;
		}

		return NullValue();
	}

	/**
	 * Mappa hash -> json_data per un elenco di hash, con una sola query.
	 * Serve alle stampe, che devono ricomporre il codice export di tutte le
	 * voci del documento senza una lettura per riga.
	 */
	public Struct function mapJsonDataByHashes( required Array hashes ){
		var map = {};

		if ( !ArrayLen( arguments.hashes ) ) {
			return map;
		}

		var records = getDao().findByHashes( arguments.hashes );

		for ( var record in records ) {
			map[ record.hash ] = record.json_data;
		}

		return map;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		Numeric productHashId,
		String hash,
		String jsonData
	){
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie gli ID restituiti dalla find per un caricamento batch
		var ids = [];
		for ( var record in records ) {
			ids.add( record.product_hash_id );
		}

		var beanMap = {};

		// Carica tutti i record completi in un'unica query e costruisce una mappa id -> bean
		if ( ids.len() ) {
			var fullRecords = getDao().readByIds( ids );

			for ( var fullRecord in fullRecords ) {
				beanMap[ fullRecord.product_hash_id ] = buildFromRow( fullRecord );
			}

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				rows.add( beanMap[ record.product_hash_id ] );
			}
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String productHashId ){
		var outcome = super.bean( "Outcome" );
		var obj = get( arguments.productHashId );

		outcome.setData( { productHashId = arguments.productHashId } );

		transaction {
			try {
				getDao().delete( arguments.productHashId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProductHash" );
				outcome.setMessage( "Cannot delete product item [#arguments.productHashId#]" );
			}
		}

		return outcome;
	}


	public Numeric function create( required com.apirone.core.model.bean.ProductHash productHash ){
		var id = getDao().insert( arguments.productHash );

		return id;
	}

	public Numeric function update( required com.apirone.core.model.bean.ProductHash productHash ){
		getDao().update( arguments.productHash );

		return arguments.productHash.getId();
	}

	/**
	 * Costruisce un bean ProductHash a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.ProductHash function buildFromRow( required any record ){
		var bean = super.bean( "ProductHash" );

		// Campi diretti dal record
		bean.setId( record.product_hash_id );
		bean.setHash( record.hash );
		bean.setJsonData( record.json_data );

		return bean;
	}

	private com.apirone.core.model.bean.ProductHash function build( required Numeric productHashId ){
		var record = getDao().read( arguments.productHashId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/*
		Calcola l'hash dell'item. Il parametro opzionale preloadedQuotationItem
		(atteso: bean QuotationItem) permette al chiamante di riusare un bean già
		caricato, evitando un secondo build completo dell'item.
		Con computeOnly=true restituisce solo l'MD5 dell'impronta senza interrogare
		il DB (né cerca né crea la riga su product_hashes): serve per i confronti
		con l'hash salvata sull'item (es. QuotationItemService.update).
	*/
	public String function createHash( required String quotationItemId, preloadedQuotationItem = javacast( "null", "" ), Boolean computeOnly = false ){
		// Senza bean pre-caricato: carica l'item completo via batch getMany()
		// invece del singolo get() -> buildFromRow() che causa cascata N+1
		var quotationItem = arguments.preloadedQuotationItem;
		if ( IsNull( quotationItem ) ) {
			var beanMap = getQuotationItemService().getMany( [ arguments.quotationItemId ] );
			quotationItem = StructKeyExists( beanMap, arguments.quotationItemId )
				? beanMap[ arguments.quotationItemId ]
				: NullValue();
		}

		var jsonData = prepareQuotationItemJson( quotationItem );

		if (IsInstanceOf( quotationItem, "com.apirone.core.model.bean.QuotationItemSignage")) {
			jsonData = prepareQuotationItemSignageJson( quotationItem, jsonData );

		} else if (IsInstanceOf( quotationItem, "com.apirone.core.model.bean.QuotationItemPlate")) {
			jsonData = prepareQuotationItemPlateJson( quotationItem, jsonData );
		}

		// Modalità confronto: restituisce solo l'MD5 dell'impronta senza cercare o
		// creare la riga su product_hashes (zero query). Serve a chi deve solo confrontare
		// l'impronta con quella salvata sull'item (es. QuotationItemService.update).
		if ( arguments.computeOnly ) {
			var digested = serializeAndHash( jsonData );

			return digested.md5;
		}

		var bean = prepareBean(jsonData);

		if (IsNull( bean.getId() ) or Trim(bean.getId()) == '') {
			create( bean );
		}

		return bean.getHash();
	}

	private function prepareQuotationItemJson( required com.apirone.core.model.bean.QuotationItem quotationItem ){
		var categoryId = quotationItem.getProduct().getCategory().getId();
		var lineId = quotationItem.getProduct().getLine().getId();
		var modelId = quotationItem.getProduct().getModel().getId();
		var finishId = quotationItem.getProduct().getFinish().getId();
		var note = quotationItem.getNote();
		var special = quotationItem.getSpecial();
		var items = quotationItem.getItems();

		var productItems = [];
		if (!isNull(items)) {
			var sortedItems = sortItemsByTree( items );

			for (var item in sortedItems) {
				productItems.append( { "productItemId" = item.getProductItem().getId(), "note" = Trim( item.getNote() ) } );
			}
		}

		var jsonData = {
			"categoryId": categoryId,
			"lineId": lineId,
			"modelId": modelId,
			"productId": quotationItem.getProduct().getId(),
			"finishId": finishId,
			"note": note,
			"special": special,
			"productItems": productItems
		};

		// Con "speciale" attivo l'impronta non deve mai coincidere con quella di
		// un ALTRO item a parità di tutti gli altri attributi (altrimenti
		// l'esportazione riuserebbe il colore già assegnato a quell'altro item):
		// il sale è l'id dell'item stesso, non un valore casuale. Così l'hash
		// resta stabile sui risalvataggi finché non cambia davvero un campo
		// (stesso id + stessi altri campi = stesso JSON = stesso hash, colore
		// già assegnato non tocca), e cambia solo quando cambia qualcos'altro
		// nella configurazione (nuovo JSON = nuovo hash = nuovo colore al
		// prossimo export).
		if ( special ) {
			jsonData[ "specialSalt" ] = quotationItem.getId();
		}

		return jsonData;
	}

	private function prepareQuotationItemSignageJson( required com.apirone.core.model.bean.QuotationItemSignage quotationItem, jsonData ){
		jsonData['signageConfigItemId'] = quotationItem.getSignageConfigItem().getId()
		var rows = quotationItem.getSignageRows() ?: [];

		arraySort(rows, function(a, b) {
			return compare(a.getOrderBy(), b.getOrderBy());
		});

		var signageRows = [];
		for (var row in rows) {
			signageRows.append( { 'text-align' = Trim( row.getTextAlign() ), 'content' = Trim( row.getContent() ) } );
		}
		jsonData['signageRows'] = signageRows;

		return jsonData;
	}

	private function prepareQuotationItemPlateJson( required com.apirone.core.model.bean.QuotationItemPlate quotationItem, jsonData ){
		var rows = quotationItem.getFruits();

		arraySort(rows, function(a, b) {
			return compare(a.getPositions()[1].order, b.getPositions()[1].order);
		});

		var quotationItemFruits = [];
		for (var row in rows) {
			var fruit = row.getFruit()
			var fruitRows = row.getItems();
			var fruitItems = [];

			if ( !isNull( fruitRows ) && fruitRows.len() ) {
				fruitRows = sortItemsByTree( fruitRows );

				for (var fruitRow in fruitRows) {
					var fruitItem = { "productItemId" = fruitRow.getProductItem().getId(), "note" = Trim( fruitRow.getNote() ) };

					// la posizione dell'incisione fa parte della configurazione: la stessa
					// combinazione con il simbolo in due posizioni diverse è un articolo diverso.
					// La chiave si aggiunge solo quando c'è un marker, così gli hash già
					// calcolati (e i codici export collegati) restano validi.
					if ( !IsNull( fruitRow.getEngravingMarkerId() ) ) {
						fruitItem[ "engravingMarkerId" ] = fruitRow.getEngravingMarkerId();
					}

					fruitItems.append( fruitItem );
				}
			}

			quotationItemFruits.append( { 'position' = Trim( row.getPositions()[1].order ), 'product' = row.getFruit().getId(), 'productItems' = fruitItems } );
		}
		jsonData['fruits'] = quotationItemFruits;

		// L'orientamento (HOR/VER) fa parte del codice variante export delle placche:
		// la stessa placca orizzontale e verticale sono articoli diversi.
		var frame = quotationItem.getFrame();
		if ( !IsNull( frame ) && !IsNull( frame.getOrientation() ) && Len( frame.getOrientation().getId() ) ) {
			jsonData['orientationId'] = frame.getOrientation().getId();
		}

		return jsonData;
	}

	/*
		Ordina gli item selezionati (QuotationItemProductItem[]) seguendo la vera gerarchia
		dell'albero attributi - genitore, poi i suoi figli, ricorsivamente - invece di un
		confronto piatto sul solo orderBy del ProductItem: orderBy ordina esclusivamente i
		VALORI dello STESSO attributo/genitore (indice DB product_items(product_id,
		origin_id, orderby)), quindi confrontarlo fra item di attributi diversi produce un
		ordine arbitrario. Bug scoperto sul codice variante export: gli attributi
		comparivano in un ordine diverso da quello mostrato nell'albero della modale.

		Pubblica (non solo per l'hash): usata anche da QuotationItemService/
		QuotationItemFruitService per ordinare gli item mostrati nelle stampe, che prima
		uscivano nell'ordine (casuale) della UUID di quotation_item_product_items.
	*/
	public Array function sortItemsByTree( required Array items ){
		var childrenByOrigin = {};
		var roots = [];

		for ( var item in arguments.items ) {
			var origin = item.getProductItem().getOrigin();
			if ( IsNull( origin ) ) {
				roots.append( item );
			} else {
				var key = "o" & origin.getId();
				if ( !StructKeyExists( childrenByOrigin, key ) ) {
					childrenByOrigin[ key ] = [];
				}
				childrenByOrigin[ key ].append( item );
			}
		}

		return flattenSiblingsByOrderBy( roots, childrenByOrigin );
	}

	/*
		Ordina un gruppo di fratelli (stesso genitore, quindi stesso scope di orderBy) e
		per ciascuno accoda ricorsivamente i suoi figli, anch'essi ordinati fra loro.
	*/
	private Array function flattenSiblingsByOrderBy( required Array siblings, required Struct childrenByOrigin ){
		// Numerico, non compare(): orderBy è una stringa numerica e compare() confronta
		// testualmente ("10" finirebbe prima di "2").
		ArraySort( arguments.siblings, function( a, b ){
			return Val( a.getProductItem().getOrderBy() ) - Val( b.getProductItem().getOrderBy() );
		} );

		var result = [];
		for ( var item in arguments.siblings ) {
			result.append( item );

			var key = "o" & item.getProductItem().getId();
			if ( StructKeyExists( arguments.childrenByOrigin, key ) ) {
				var children = flattenSiblingsByOrderBy( arguments.childrenByOrigin[ key ], arguments.childrenByOrigin );
				for ( var child in children ) {
					result.append( child );
				}
			}
		}

		return result;
	}

	/*
		Ordina le chiavi di primo livello del JSON dell'item, lo serializza e ne calcola
		l'MD5. Restituisce { json = testo serializzato, md5 = impronta }. Separato da
		prepareBean() per poter confrontare l'impronta con quella salvata senza toccare il DB.
	*/
	private Struct function serializeAndHash( jsonData ){
		var sorted = sortTopLevelStruct( arguments.jsonData );
		var serialized = serializeJson( sorted );

		return { "json" = serialized, "md5" = hash( serialized, "MD5" ) };
	}

	private function prepareBean( jsonData ){
		var digested = serializeAndHash( arguments.jsonData );

		var existProductHash = search( jsonData = digested.json );

		if ( existProductHash.getCount() > 0 ) {
			return existProductHash.getData()[1]
		}

		var bean = super.bean( "ProductHash" );
		bean.setHash( digested.md5 );
		bean.setJsonData( digested.json );

		return bean;
	}

	function sortTopLevelStruct(s) {
		var result = structNew("ordered");

		var keys = structKeyArray(s);
		arraySort(keys, "textnocase");

		for (var k in keys) {
			result[k] = s[k];
		}

		return result;
	}
}
