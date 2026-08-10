component extends="com.apirone.core.controller.AbsController" {

	// Mappa tipologia di stampa -> template. Le voci sono sempre unite per hash: il
	// secondo livello della dialog ( groupByCategory ) decide solo se spezzarle in
	// sezioni per tipo di categoria, non quale template usare.
	// La proforma riusa il template del preventivo: le differenze ( testata, validità,
	// pagamento, totale a pagare, avviso non fiscale ) sono condizionate lì su params.report.
	variables.REPORT_TEMPLATES = {
		'classic'   = 'print-quotation-classic',
		'photo'     = 'print-quotation-photo-grouped',
		'technical' = 'print-quotation-technical-grouped',
		'proforma'  = 'print-quotation-classic'
	};

	function print(event, rc, prc) {

		var idPreventivo = rc.id;
		var printParams = {
			'report' = StructKeyExists( rc, 'report' ) ? rc.report : 'classic',
			'images' = printFlag( rc, 'images' ),
			'note' = printFlag( rc, 'note' ),
			'groupByCategory' = printFlag( rc, 'groupByCategory' ),
			'discounts' = printFlag( rc, 'discounts' ),
			'plants' = printFlag( rc, 'plants' ),
			'hideTotal' = printFlag( rc, 'hideTotal' ),
			'progressivo' = StructKeyExists( rc, 'progressivo' ) ? Trim( rc.progressivo ) : '',
			'percentuale' = StructKeyExists( rc, 'percentuale' ) && IsNumeric( rc.percentuale ) ? Val( rc.percentuale ) : 0
		}

		// La proforma non riporta mai le foto degli articoli.
		if ( printParams.report == 'proforma' ) {
			printParams.images = false;
		}

		if ( !StructKeyExists( variables.REPORT_TEMPLATES, printParams.report ) ) {
			Throw( message = "Tipologia di stampa non riconosciuta: #printParams.report#" );
		}

		var templatePath = "report/template/" & variables.REPORT_TEMPLATES[ printParams.report ];

		prc.title = "Preventivo";

		var quotation = service("Quotation").get(quotationId = idPreventivo);
		var quotationPrice = service("QuotationPrice").getByQuotationId(quotationId = idPreventivo);

		var quoteObj = {
			quotation      = quotation,
			quotationPrice = quotationPrice,
			quotationItems = []
		};

		if (IsNull( quotationPrice) ) {
			Throw(
				message = "
				Preventivo non calcolato"
			);
			return;
		}

		quoteObj = printClassic( quoteObj, printParams );

		var customerShippingProfile = {
			'name' = '',
			'via' = '',
			'cap' = '',
			'citta' = '',
			'provincia' = '',
			'paese' = ''
		};

		if (!isNull(quotation.getCustomer()) && !isNull(quotation.getCustomer().getShippingProfiles()) && quotation.getCustomer().getShippingProfiles().len() > 0) {
			customerShippingProfile = quotation.getCustomer().getShippingProfiles()[1];
		}

		```
		<cfquery name="total" datasource="apirone">
			SELECT SUM(amount) AS total
			FROM quotation_items
				INNER JOIN quotation_item_prices ON quotation_items.quotation_item_id = quotation_item_prices.quotation_item_id
			WHERE 1=1
				AND quotation_items.quotation_id = '#idPreventivo#'
		</cfquery>
		```
		quoteObj.totalSpent = total.total;

		var saveAsName = "print-quotation-#printParams.report#_#printParams.groupByCategory ? 'categorie' : 'lista'#_#DateTimeFormat(Now(), 'yyyyMMdd-HHnnss')#.pdf";

		var params = {
			title   = "Preventivo",
			data    = quoteObj,
			params  = printParams,
			pdfArgs = {
				bookmark          = true,
				backgroundVisible = true,
				orientation       = "portrait",
				pageType          = "A4",
				overwrite         = true,
				fontEmbed         = true,
				saveAsName        = saveAsName
			}
		}

		event.renderData( data = view( view = templatePath, args = params ), type = "PDF" );
	}

	// NON PIÙ INVOCATA. Costruisce i dati per zona ( quoteObj.zones ) per i template
	// print-quotation-zone / -photo / -technical, anch'essi non più raggiungibili da
	// quando il secondo livello della dialog decide solo le sezioni per categoria.
	// Conservata per poter ripristinare la stampa per zona senza riscriverla.
	function printZone( quoteObj, printParams ) {
		var quotation = quoteObj.quotation;
		var idPreventivo = quotation.getId();

		//ordiniamo le zone in modo da avere prima quelle padre
		var zones = super.fire('QuotationZone.list', [ 'quotationId' = idPreventivo, 'orderby' = [ { field = "quotationItemZone.originId", dir = "desc" } ] ]);

		var sortedZones = [];
		for (var zone in zones) {
			if (zone.getName() == 'Non assegnato') {
				var unassignedZone = zone;
				continue;
			}
			//aggiungiamo le zone figlie ad ogni zona padre
			if (isNull(zone.getOrigin())) {
				sortedZones.add(zone)
				var subZones = super.fire('QuotationZone.list', [ 'quotationId' = idPreventivo, 'originId' = zone.getId() ])
				for ( var subZone in subZones ) {
					sortedZones.add(subZone)
				}
			}
		}
		sortedZones.add(unassignedZone);
		var articleItems = [];
		for ( var i = 1; i LTE ArrayLen( sortedZones ); i++ ) {
			var zone = sortedZones[i];
			//se stampa raggruppata
			if (printParams.grouped) {
				if (!isNull((zone.getOrigin()))) {
					continue;
				}
				//delle zone padre aggiungiamo gli items
				var zoneItems = super.fire('QuotationItem.list', [ 'quotationId' = idPreventivo, 'quotationZoneId' = zone.getId() ]);
				var subZones = zones.filter(function(item) {
					return !isNull(item.getOrigin()) && item.getOrigin().getId() == zone.getId()
				})
				//aggiungiamo gli items delle zone figlie
				for ( var subZone in subZones ) {
					var thisSubZoneItems = super.fire('QuotationItem.list', [ 'quotationId' = idPreventivo, 'quotationZoneId' = subZone.getId() ]);
					arrayAppend(zoneItems, thisSubZoneItems, true);
				}
				//se stampa non raggruppata ad ogni zona o sottozona assegnamo gli items
			} else {
				var zoneItems = super.fire('QuotationItem.list', [ 'quotationId' = idPreventivo, 'quotationZoneId' = zone.getId() ]);
			}
			if (zone.getName() == 'Non assegnato') {
				articleItems = zoneItems.filter(function(item) {
					return !isNull(item.getArticle())
				});
			}
			zoneItems = zoneItems.filter(function(item) {
				return isNull(item.getArticle())
			})
			zone.zoneItems = zoneItems;
		}

		if (printParams.grouped) {
			sortedZones = sortedZones.filter(function(item) {
				return isNull(item.getOrigin())
			})
		}

		quoteObj.zones = sortedZones;
		quoteObj.articleItems = articleItems;

		var allItems = [];
		for ( var z in sortedZones ) {
			arrayAppend( allItems, z.zoneItems, true );
		}
		quoteObj.modelConfigMap = buildModelConfigMap( allItems );

		return quoteObj;
	}


	function printClassic( quoteObj, printParams ) {
		var quotation = quoteObj.quotation;
		var idPreventivo = quotation.getId();
		var items = super.fire('QuotationItem.list', [ 'quotationId' = idPreventivo ]);
		var productItems = items.filter(function(item) {
			return !isNull(item.getProduct())
		});
		var articleItems = items.filter(function(item) {
			return !isNull(item.getArticle())
		});
		items = groupItems(productItems);
		quoteObj.items = items;
		quoteObj.itemGroups = groupByCategoryType( items, printParams.groupByCategory ?: false );
		quoteObj.articleItems = articleItems;

		// Piante: in testa al documento quando le voci sono in elenco unico,
		// dentro ogni sezione quando sono separate per categoria.
		quoteObj.plants = [];
		for ( var group in quoteObj.itemGroups ) {
			group.plants = [];
		}

		if ( printParams.plants ?: false ) {
			if ( printParams.groupByCategory ?: false ) {
				for ( var group in quoteObj.itemGroups ) {
					group.plants = buildPlants( idPreventivo, group.id );
				}
			} else {
				quoteObj.plants = buildPlants( idPreventivo );
			}
		}

		var allItems = [];
		for ( var hashKey in quoteObj.items ) {
			arrayAppend( allItems, quoteObj.items[hashKey].item );
		}
		quoteObj.modelConfigMap = buildModelConfigMap( allItems );

		return quoteObj;
	}

	private Boolean function printFlag( required Struct rc, required String key ){
		return StructKeyExists( arguments.rc, arguments.key ) && arguments.rc[ arguments.key ] == 'true';
	}

	private Struct function buildModelConfigMap( required Array items ){
		var map = {};
		for ( var item in arguments.items ) {
			if ( isNull( item.getProduct() ) ) continue;
			var productId = item.getProduct().getId();
			if ( StructKeyExists( map, productId ) ) continue;
			var prod = item.getProduct();
			if ( isNull( prod.getModel() ) || isNull( prod.getLine() ) || isNull( prod.getCategory() ) ) continue;
			var configs = service( "ModelConfig" ).list(
				modelId           = prod.getModel().getId(),
				lineId            = prod.getLine().getId(),
				productCategoryId = prod.getCategory().getId()
			);
			if ( ArrayLen( configs ) ) {
				map[ productId ] = configs[1];
			}
		}
		return map;
	}

	/**
	 * Raggruppa le righe già unite per hash nei tipi di categoria prodotto
	 * ( Placche, Frutti, Segnaletica, Accessori ), nell'ordine di
	 * product_category_types.orderby. Le righe senza tipo finiscono in coda.
	 *
	 * Con byCategory = false restituisce un gruppo unico e senza nome, con tutte le
	 * righe ordinate per hash: stessa stampa, senza le intestazioni di sezione.
	 *
	 * NB: groupItems() restituisce una Struct, che non ha ordine: l'ordinamento
	 * va quindi ricostruito qui, non prima.
	 *
	 * @return Array di { id, name, orderby, items }, items ordinati per hash
	 */
	private Array function groupByCategoryType( required Struct groupedItems, required Boolean byCategory ){
		if ( !arguments.byCategory ) {
			var flat = [];
			for ( var hashKey in arguments.groupedItems ) {
				ArrayAppend( flat, arguments.groupedItems[ hashKey ] );
			}
			ArraySort( flat, function( a, b ){
				return Compare( itemSortKey( a ), itemSortKey( b ) );
			} );

			return [ { 'id' = '', 'name' = '', 'orderby' = 0, 'items' = flat } ];
		}

		var buckets = {};

		for ( var hashKey in arguments.groupedItems ) {
			var entry  = arguments.groupedItems[ hashKey ];
			var type   = categoryTypeOf( entry.item );
			var typeId = IsNull( type ) ? "" : type.getId();

			if ( !StructKeyExists( buckets, typeId ) ) {
				var orderby = 999999;
				var name    = "";

				if ( !IsNull( type ) ) {
					if ( !IsNull( type.getName() ) ) name = type.getName();
					if ( !IsNull( type.getOrderby() ) ) orderby = type.getOrderby();
				}

				buckets[ typeId ] = { 'id' = typeId, 'name' = name, 'orderby' = orderby, 'items' = [] };
			}

			ArrayAppend( buckets[ typeId ].items, entry );
		}

		var groups = [];
		for ( var key in buckets ) {
			ArrayAppend( groups, buckets[ key ] );
		}

		ArraySort( groups, function( a, b ){
			if ( a.orderby NEQ b.orderby ) return a.orderby LT b.orderby ? -1 : 1;
			return Compare( a.name, b.name );
		} );

		for ( var group in groups ) {
			ArraySort( group.items, function( a, b ){
				return Compare( itemSortKey( a ), itemSortKey( b ) );
			} );
		}

		return groups;
	}

	/**
	 * Piante da stampare: una per ogni zona che ha una planimetria e almeno un marker
	 * visibile. Con categoryTypeId valorizzato tiene solo i marker di quel tipo, così
	 * ogni sezione di categoria ha le sue piante dedicate.
	 *
	 * Il disegno è ricostruito dai dati ( coordinate 0-1, angolo, moltiplicatore ) e non
	 * dalla cattura html2canvas della pagina Posizioni in pianta, che vive nel browser.
	 *
	 * @return Array di { zoneName, imagePath, markers = [ { x, y, size, angle, color, label } ] }
	 */
	private Array function buildPlants( required String quotationId, String categoryTypeId = "" ){
		var plants = [];
		var zones  = super.fire( 'QuotationZone.list', [ 'quotationId' = arguments.quotationId ] );

		for ( var zone in zones ) {
			if ( IsNull( zone.getImage() ) ) continue;

			var items   = super.fire( 'QuotationItem.list', [ 'quotationId' = arguments.quotationId, 'quotationZoneId' = zone.getId() ] );
			var markers = [];

			for ( var item in items ) {
				if ( IsNull( item.getProduct() ) || IsNull( item.getPositions() ) ) continue;

				var type   = categoryTypeOf( item );
				var typeId = IsNull( type ) ? "" : type.getId();

				if ( Len( arguments.categoryTypeId ) && typeId != arguments.categoryTypeId ) continue;

				for ( var pos in item.getPositions() ) {
					if ( IsNull( pos.getVisible() ) || !pos.getVisible() ) continue;

					var size = Round( 35 * ( Val( pos.getSizeMultiplier() ?: 100 ) / 100 ) );

					ArrayAppend( markers, {
						'x'     = Val( pos.getCoordinateX() ) * 100,
						'y'     = Val( pos.getCoordinateY() ) * 100,
						'size'  = size,
						'angle' = Val( pos.getAngle() ?: 0 ) + 135,
						'color' = markerColor( item ),
						'label' = markerLabel( item )
					} );
				}
			}

			if ( ArrayLen( markers ) ) {
				// Il box di disegno va dato in centimetri: cfdocument non applica
				// max-width/max-height, e senza dimensioni esplicite il posizionamento
				// percentuale dei marker non avrebbe un riferimento.
				var imgWidth  = Val( zone.getImage().getWidth() ?: 0 );
				var imgHeight = Val( zone.getImage().getHeight() ?: 0 );
				var boxWidth  = 17;
				var boxHeight = imgWidth GT 0 && imgHeight GT 0 ? boxWidth * imgHeight / imgWidth : boxWidth * 0.75;

				// non oltre l'altezza utile della pagina
				if ( boxHeight GT 20 ) {
					boxWidth  = boxWidth * 20 / boxHeight;
					boxHeight = 20;
				}

				ArrayAppend( plants, {
					'zoneName'  = zone.getName(),
					'imagePath' = plantImagePath( zone.getImage() ),
					'boxWidth'  = NumberFormat( boxWidth, "9.99" ),
					'boxHeight' = NumberFormat( boxHeight, "9.99" ),
					'markers'   = markers
				} );
			}
		}

		return plants;
	}

	/**
	 * Percorso su disco della planimetria, per cfdocument.
	 *
	 * Non si usa File.getPath() perché applica ExpandPath due volte e finisce per
	 * ri-radicare un percorso già assoluto sotto la webroot ( /app/repository/... ).
	 * Il repository media sta fuori dalla webroot in produzione e dentro /public in
	 * sviluppo, quindi si prova l'uno e poi l'altro; in ultima istanza si ripiega
	 * sull'URI http, che cfdocument sa scaricare.
	 */
	private String function plantImagePath( required any file ){
		var relative = arguments.file.getRelativePath();

		for ( var root in [ ExpandPath( "/../repository/public" ), ExpandPath( "/public" ) ] ) {
			var candidate = root & relative;

			if ( FileExists( candidate ) ) {
				return candidate;
			}
		}

		return arguments.file.getUri();
	}

	// Stessa scala colori di getColor() in app-quotation-plant-positions.js.
	private String function markerColor( required any quotationItem ){
		var product  = arguments.quotationItem.getProduct();
		var category = NullValue();

		if ( !IsNull( product ) && !IsNull( product.getCatalogBundle() ) && !IsNull( product.getCatalogBundle().getCategory() ) ) {
			category = product.getCatalogBundle().getCategory();
		} else if ( !IsNull( product ) && !IsNull( product.getCategory() ) ) {
			category = product.getCategory();
		}

		if ( IsNull( category ) ) return "rgb(232, 93, 68)";

		var typeId  = !IsNull( category.getType() ) ? category.getType().getId() : "";
		var catName = UCase( category.getName() ?: "" );

		if ( typeId == "PLA" ) return "rgb(68, 130, 232)";
		if ( catName CONTAINS "EMERGENZA" ) return "rgb(220, 30, 30)";
		if ( catName CONTAINS "INTERNA" ) return "rgb(34, 139, 34)";
		if ( catName CONTAINS "ESTERNA" ) return "rgb(139, 90, 43)";

		return "rgb(128, 0, 128)";
	}

	// Come formatLabelText(): codice posizione troncato a 3 caratteri.
	private String function markerLabel( required any quotationItem ){
		var code = "";

		if ( !IsNull( arguments.quotationItem.getPosition() ) ) {
			code = arguments.quotationItem.getPosition().getCode() ?: "";
		}

		return Left( Len( code ) ? code : "N/A", 3 );
	}

	private any function categoryTypeOf( required any quotationItem ){
		var product = arguments.quotationItem.getProduct();

		if ( IsNull( product ) || IsNull( product.getCategory() ) ) {
			return NullValue();
		}

		return product.getCategory().getType();
	}

	function groupItems( quotationItems ) {
		var groupedItems = {};

		for ( var quotationItem in quotationItems ) {
			var hashKey = quotationItem.getHash();
			var zone    = quotationItem.getQuotationZone();

			var zoneQuantity = !isNull( zone.getOrigin() ) ?
				zone.getOrigin().getQuantity() * zone.getQuantity() :
				zone.getQuantity();

			var itemQuantity = quotationItem.getQuantity() * zoneQuantity;

			if ( !structKeyExists( groupedItems, hashKey ) ) {
				groupedItems[hashKey] = {
					'item' = quotationItem,
					'quantity' = itemQuantity,
					'zones' = {},
					'positionCodes' = []
				};
			} else {
				groupedItems[hashKey].quantity += itemQuantity;
			}

			var zoneName = zone.getName();

			if ( !structKeyExists( groupedItems[hashKey].zones, zoneName ) ) {
				// quantity serve quando la riga non ha codice posizione: si stampa quella
				groupedItems[hashKey].zones[ zoneName ] = { 'positions' = [], 'quantity' = 0 };
			}

			groupedItems[hashKey].zones[ zoneName ].quantity += itemQuantity;

			var position = quotationItem.getPosition();
			var code     = !isNull( position ) ? ( position.getCode() ?: "" ) : "";

			if ( Len( code ) ) {
				// NB: il confronto va fatto sul codice, non sull'oggetto posizione
				if ( !arrayContains( groupedItems[hashKey].zones[ zoneName ].positions, code ) ) {
					arrayAppend( groupedItems[hashKey].zones[ zoneName ].positions, code );
				}
				if ( !arrayContains( groupedItems[hashKey].positionCodes, code ) ) {
					arrayAppend( groupedItems[hashKey].positionCodes, code );
				}
			}
		}

		return groupedItems;
	}

	/**
	 * Chiave di ordinamento di riga: prima le voci con codice posizione, in ordine
	 * alfanumerico naturale; poi quelle senza, nell'ordine manuale del preventivo.
	 */
	private String function itemSortKey( required Struct entry ){
		if ( ArrayLen( arguments.entry.positionCodes ) ) {
			var best = positionSortKey( arguments.entry.positionCodes[ 1 ] );

			for ( var code in arguments.entry.positionCodes ) {
				var key = positionSortKey( code );
				if ( Compare( key, best ) LT 0 ) best = key;
			}

			return "A" & best;
		}

		return "B" & NumberFormat( Val( arguments.entry.item.getOrdinamento() ?: 0 ), "0000000000" );
	}

	/**
	 * Rende un codice posizione confrontabile come stringa mantenendo l'ordine
	 * naturale dei numeri: le cifre vengono allineate a 10 posizioni, così "2"
	 * precede "10" e "EL-2" precede "EL-15".
	 */
	private String function positionSortKey( required String code ){
		var key    = "";
		var digits = "";
		var text   = LCase( Trim( arguments.code ) );

		for ( var i = 1; i LTE Len( text ); i++ ) {
			var c = Mid( text, i, 1 );

			if ( REFind( "[0-9]", c ) ) {
				digits &= c;
				continue;
			}

			if ( Len( digits ) ) {
				key &= RepeatString( "0", Max( 0, 10 - Len( digits ) ) ) & digits;
				digits = "";
			}

			key &= c;
		}

		if ( Len( digits ) ) {
			key &= RepeatString( "0", Max( 0, 10 - Len( digits ) ) ) & digits;
		}

		return key;
	}
}
