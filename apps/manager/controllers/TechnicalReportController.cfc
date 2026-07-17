component extends="com.apirone.core.controller.AbsController" {

	function print(event, rc, prc) {

		var idPreventivo = rc.id;
		var printParams = {
			'report' = rc.report,
			'images' = rc.images == 'true',
			'note' = rc.note == 'true',
			'grouped' = rc.grouped == 'true',
			'discounts' = rc.discounts == 'true',
			'hideTotal' = StructKeyExists( rc, 'hideTotal' ) && rc.hideTotal == 'true'
		}

		var templatePath = "report/template/print-quotation-#rc.report#";
		templatePath = templatePath & (printParams.grouped ? '-grouped' : '')

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

		switch(printParams.report){
			case 'zone':
				quoteObj = printZone( quoteObj, printParams );
				break;
			case 'classic':
				quoteObj = printClassic( quoteObj, printParams );
				break;
			case 'technical':
				if (printParams.grouped) {
					quoteObj = printClassic( quoteObj, printParams );
				} else {
					quoteObj = printZone( quoteObj, printParams );
				}
				break;
			case 'photo':
				if (printParams.grouped) {
					quoteObj = printClassic( quoteObj, printParams );
				} else {
					quoteObj = printZone( quoteObj, printParams );
				}
				break;
			default:
				return;
		}

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

		var saveAsName = "print-quotation-#printParams.report##printParams.grouped ? '_grouped_' : '_'##DateTimeFormat(Now(), 'yyyyMMdd-HHnnss')#.pdf";

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
		items = productItems.sort(sortByCategory);
		items = groupItems(items);
		quoteObj.items = items;
		quoteObj.articleItems = articleItems;

		var allItems = [];
		for ( var hashKey in quoteObj.items ) {
			arrayAppend( allItems, quoteObj.items[hashKey].item );
		}
		quoteObj.modelConfigMap = buildModelConfigMap( allItems );

		return quoteObj;
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

	function sortByCategory(a, b) {
		var idA = a.getProduct().getCategory().getId();
		var idB = b.getProduct().getCategory().getId();

		if (idA LT idB) return -1;
		if (idA GT idB) return 1;
		return 0;
	}

	function groupItems( quotationItems ) {
		groupedItems = {};

		for ( quotationItem in quotationItems ) {
			var hashKey = quotationItem.getHash();
			var zoneQuantity = !isNull(quotationItem.getQuotationZone().getOrigin()) ?
				quotationItem.getQuotationZone().getOrigin().getQuantity() * quotationItem.getQuotationZone().getQuantity() :
				quotationItem.getQuotationZone().getQuantity();
			if ( !structKeyExists(groupedItems, hashKey) ) {
				var quantity = quotationItem.getQuantity();
				if (len(quotationItem.getQuotationZone())) {
					quantity = quantity * zoneQuantity;
				}
				groupedItems[hashKey] = {
					'item' = quotationItem,
					'quantity' = quantity,
					'zones' = {}
				};
			} else {
				groupedItems[hashKey].quantity += (quotationItem.getQuantity() * zoneQuantity);
			}
			var zoneName = quotationItem.getQuotationZone().getName();
			var position = quotationItem.getPosition();

			if ( !structKeyExists(groupedItems[hashKey].zones, zoneName) ) {
				groupedItems[hashKey].zones[ zoneName ] = [];
			}

			if ( !arrayContains(groupedItems[hashKey].zones[zoneName], position) && !isNull(position) ) {
				arrayAppend(groupedItems[hashKey].zones[zoneName], position.getCode());
			}
		}

		return groupedItems;
	}
}
