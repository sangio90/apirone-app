/**
 * Griglia incisioni dei frutti: le posizioni ammesse per il simbolo inciso, per frutto e
 * per attributo radice dell'incisione (IS, II, IL). Vedi piano-griglia-incisioni.md.
 */
component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ProductEngravingMarkerDAO";
	property name="productItemService" inject="ProductItemService";
	property name="fileService" inject="FileService";

	public com.apirone.core.model.bean.ProductEngravingMarker function get( required String productEngravingMarkerId ){
		return build( arguments.productEngravingMarkerId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String productId,
		String attributeId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "productEngravingMarker.order", dir = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		var ids = [];
		records.each( function( record ){
			ids.append( record.product_engraving_marker_id );
		} );

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );
			for ( var r in allRecords ) {
				beanMap[ r.product_engraving_marker_id ] = buildFromRow( r );
			}
		}

		records.each( function( record ){
			rows.add( beanMap[ record.product_engraving_marker_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.ProductEngravingMarker marker ){
		return getDao().insert( arguments.marker );
	}

	/**
	 * Sostituisce in blocco la griglia di un frutto per un attributo radice: i marker
	 * vengono rinumerati 1..N nell'ordine ricevuto. Restituisce i bean salvati.
	 *
	 * La posizione N mantiene il suo id: si aggiornano i marker già presenti invece di
	 * cancellarli e ricrearli, altrimenti ogni salvataggio della griglia azzererebbe il
	 * collegamento dei preventivi (FK ON DELETE SET NULL) e le placche perderebbero la
	 * posizione scelta. Si cancellano solo i marker eccedenti.
	 */
	public Array function replaceForProductAttribute(
		required String productId,
		required String attributeId,
		required Array markers
	){
		var existing = list( productId = arguments.productId, attributeId = arguments.attributeId );

		transaction {
			var order = 1;
			for ( var marker in arguments.markers ) {
				marker.setProductId( arguments.productId );
				marker.setAttributeId( arguments.attributeId );
				marker.setOrder( order );

				if ( order <= ArrayLen( existing ) ) {
					marker.setId( existing[ order ].getId() );
					getDao().update( marker );
				} else {
					getDao().insert( marker );
				}

				order++;
			}

			if ( ArrayLen( existing ) GT ArrayLen( arguments.markers ) ) {
				getDao().deleteByProductAttributeFromOrder(
					productId   = arguments.productId,
					attributeId = arguments.attributeId,
					fromOrder   = ArrayLen( arguments.markers ) + 1
				);
			}
		}

		return list( productId = arguments.productId, attributeId = arguments.attributeId );
	}

	/**
	 * Marker di più frutti in una query: struct productId -> array di bean, ordinati per
	 * attributo e numero. Usato dalla modale placca per lo snap dei simboli.
	 */
	public Struct function listByProductIds( required Array productIds ){
		var map = {};

		if ( !ArrayLen( arguments.productIds ) ) {
			return map;
		}

		var records = getDao().readByProductIds( arguments.productIds );
		for ( var r in records ) {
			if ( !StructKeyExists( map, r.product_id ) ) {
				map[ r.product_id ] = [];
			}
			map[ r.product_id ].append( buildFromRow( r ) );
		}

		return map;
	}

	/**
	 * Immagine orizzontale su cui disegnare la griglia: quella del prodotto se c'è, altrimenti
	 * la prima fra quelle dei product item con le proporzioni del frutto (moduli × 11,25 mm
	 * per 45 mm), perché molti frutti hanno il disegno solo lì. Null se non c'è nulla di
	 * utilizzabile (il client ripiega sul placeholder generico).
	 * @return struct { uri, width, height, source } oppure null
	 */
	public Any function findBaseImage( required String productId, Numeric positionCount = 1 ){
		var records  = getDao().findBaseImages( productId = arguments.productId );
		var expected = ( 11.25 * Max( 1, arguments.positionCount ) ) / 45;

		for ( var r in records ) {
			var w = Val( r.width );
			var h = Val( r.height );
			// immagine del prodotto: va bene com'è; immagini degli item: solo se hanno le
			// proporzioni del frutto (scarta ad esempio le texture 1200x500 delle placche)
			if ( r.priority == 2 && ( w LTE 0 || h LTE 0 || Abs( ( w / h ) - expected ) GT expected * 0.15 ) ) {
				continue;
			}
			var file = getFileService().get( r.file_id );
			if ( IsNull( file ) ) {
				continue;
			}
			return { "uri" = file.getUri(), "width" = w, "height" = h, "source" = ( r.priority == 1 ? "product" : "productItem" ) };
		}

		return NullValue();
	}

	/**
	 * Codici degli attributi "radice" dell'incisione, in ordine di priorità
	 * (il primo che si incontra risalendo l'albero vince). Da Configuration.
	 */
	public Array function rootAttributeCodes(){
		var codes = super.getConfiguration().get( "engravingRootAttributeCodes" );
		return IsNull( codes ) ? [] : codes;
	}

	/**
	 * Codici degli attributi che portano il simbolo inciso (il valore posizionabile).
	 */
	public Array function symbolAttributeCodes(){
		var codes = super.getConfiguration().get( "engravingSymbolAttributeCodes" );
		return IsNull( codes ) ? [] : codes;
	}

	/**
	 * Lato in mm del riquadro con cui si disegna il simbolo inciso.
	 */
	public Numeric function symbolSizeMm(){
		var size = super.getConfiguration().get( "engravingSymbolSizeMm" );
		return ( IsNull( size ) || !IsNumeric( size ) ) ? 10 : size;
	}

	/**
	 * Marker valido per un valore selezionato: controlla che appartenga al frutto e
	 * all'attributo radice dell'incisione a cui appartiene il product item (tipicamente
	 * il valore SIMBOLO). Null se il marker non esiste o non è coerente.
	 */
	public Any function findMarkerForProductItem(
		required String productEngravingMarkerId,
		required Numeric productItemId,
		required String productId
	){
		var marker = get( arguments.productEngravingMarkerId );

		if ( IsNull( marker ) || IsNull( marker.getId() ) || !Len( marker.getId() ) ) {
			return NullValue();
		}

		if ( marker.getProductId() != arguments.productId ) {
			return NullValue();
		}

		if ( marker.getAttributeId() != resolveRootAttributeId( arguments.productItemId ) ) {
			return NullValue();
		}

		return marker;
	}

	/**
	 * Attributi radice dell'incisione presenti su un frutto: array di { id, code, name }.
	 */
	public Array function listEngravingAttributes( required String productId, String langId = "IT" ){
		var codes = rootAttributeCodes();
		if ( !ArrayLen( codes ) ) {
			return [];
		}

		var records = getDao().findEngravingAttributes( productId = arguments.productId, codes = codes, langId = arguments.langId );
		var rows    = [];
		for ( var r in records ) {
			rows.append( { "id" = r.attribute_id, "code" = r.code, "name" = ( IsNull( r.name ) ? r.code : r.name ) } );
		}

		// nell'ordine di priorità dei codici (IS, II, IL), non alfabetico
		ArraySort( rows, function( a, b ){
			return ArrayFind( codes, a.code ) - ArrayFind( codes, b.code );
		} );

		return rows;
	}

	/**
	 * Attributo radice della griglia a cui appartiene un product item (tipicamente il
	 * valore SIMBOLO): risale la catena origin_id e restituisce l'attributo più in alto
	 * fra quelli radice. Stringa vuota se la catena non tocca nessun attributo radice.
	 */
	public String function resolveRootAttributeId( required Numeric productItemId ){
		var codes  = rootAttributeCodes();
		var rootId = "";
		var guard  = 0;

		var current = getProductItemService().get( arguments.productItemId );

		while ( !IsNull( current ) && guard < 10 ) {
			guard++;

			var attribute = current.getAttribute();
			if ( !IsNull( attribute ) && ArrayFind( codes, attribute.getCode() ) ) {
				rootId = attribute.getId();
			}

			if ( IsNull( current.getOrigin() ) || IsNull( current.getOrigin().getId() ) ) {
				break;
			}

			current = getProductItemService().get( current.getOrigin().getId() );
		}

		return rootId;
	}

	private com.apirone.core.model.bean.ProductEngravingMarker function build( required String productEngravingMarkerId ){
		var record = getDao().read( arguments.productEngravingMarkerId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	private com.apirone.core.model.bean.ProductEngravingMarker function buildFromRow( required any record ){
		var bean = super.bean( "ProductEngravingMarker" );

		bean.setId( arguments.record.product_engraving_marker_id );
		// readByIds legge le colonne uuid come oggetti Java: si passano come stringhe
		bean.setProductId( IsNull( arguments.record.product_id ) ? "" : arguments.record.product_id.toString() );
		bean.setAttributeId( IsNull( arguments.record.attribute_id ) ? "" : arguments.record.attribute_id.toString() );
		bean.setOrder( arguments.record.order );
		bean.setXPx( arguments.record.x_px );
		bean.setYPx( arguments.record.y_px );
		bean.setXMm( arguments.record.x_mm );
		bean.setYMm( arguments.record.y_mm );
		bean.setCreatedAt( arguments.record.created_at );

		return bean;
	}

}
