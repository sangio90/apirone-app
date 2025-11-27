component extends="com.apirone.core.controller.AbsController" {

	function print(event, rc, prc) {

		var idPreventivo = rc.id;
		var printParams = {
			'report' = rc.report,
			'images' = rc.images == 'true',
			'notes' = rc.notes == 'true',
			'grouped' = rc.grouped == 'true',
			'discounts' = rc.discounts == 'true',
		}

		var templatePath = "report/template/print-quotation-#rc.report#";
		templatePath = templatePath & (printParams.grouped ? '-grouped' : '')

		prc.title = "Preventivo";

		var quotation = service("Quotation").get(quotationId = idPreventivo);

		var quoteObj = {
			quotation      = quotation,
			quotationItems = []
		};

		if ( IsNull( quotation.getCustomer() ) ) {
			Throw(
				message = "
				Preventivo con cliente non valido"
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
			case 'proforma':
				quoteObj = printClassic( quoteObj, printParams );
				break;
				case 'technical':
				if (printParams.grouped) {
					quoteObj = printClassic( quoteObj, printParams );
				} else {
					quoteObj = printZone( quoteObj, printParams );
				}
				break;
			case 'internal':
				quoteObj = printZone( quoteObj, printParams );
				break;
			default:
				return;
		}

		var customerShippingAddress = [
			'name' = null,
			'via' = null,
			'cap' = null,
			'citta' = null,
			'provincia' = null,
			'paese' = null
		];

		if (!isNull(quotation.getCustomer().getShippingAddresses()) && quotation.getCustomer().getShippingAddresses().len() > 0) {
			customerShippingAddress = quotation.getCustomer().getShippingAddresses()[1];
		}

		quoteObj.customerShippingAddress = customerShippingAddress;

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

		event.renderData( data = renderView( view = templatePath, args = params ), type = "PDF" );
	}

	function printZone( quoteObj, printParams ) {
		var quotation = quoteObj.quotation;
		var idPreventivo = quotation.getId();

		//ordiniamo le zone in modo da avere prima quelle padre
		var zones = super.fire('QuotationZone.list', [ 'quotationId' = idPreventivo, 'orderby' = [ { field = "quotationItemZone.originId", dir = "desc" } ] ]);
		
		var sortedZones = [];
		for (var zone in zones) {
			//aggiungiamo le zone figlie ad ogni zona padre
			if (isNull(zone.getOrigin())) {
				sortedZones.add(zone)
				var subZones = super.fire('QuotationZone.list', [ 'quotationId' = idPreventivo, 'originId' = zone.getId() ])
				for ( var subZone in subZones ) {
					sortedZones.add(subZone)
				}
			}
		}

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
			zone.zoneItems = zoneItems;
		}

		if (printParams.grouped) {
			sortedZones = sortedZones.filter(function(item) {
				return isNull(item.getOrigin())
			})
		}

		quoteObj.zones = sortedZones;

		return quoteObj;
	}


	function printClassic( quoteObj, printParams ) {
		var quotation = quoteObj.quotation;
		var idPreventivo = quotation.getId();
		var items = super.fire('QuotationItem.list', [ 'quotationId' = idPreventivo ]);
		var items = items.sort(sortByCategory);
		if (printParams.grouped) {
			items = groupItems(items);
		}
		quoteObj.items = items;

		return quoteObj;
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
			hashKey = quotationItem.getHash();
			if ( !structKeyExists(groupedItems, hashKey) ) {
				groupedItems[hashKey] = {
					'item' = quotationItem,
					'quantity' = quotationItem.getQuantity(),
					'zones' = {}
				};
			} else {
				groupedItems[hashKey].quantity += quotationItem.getQuantity();
			}
			var zoneName = quotationItem.getQuotationZone().getName();
			var position = quotationItem.getPosition();

			if ( !structKeyExists(groupedItems[hashKey].zones, zoneName) ) {
				groupedItems[hashKey].zones[ zoneName ] = [];
			}

			if ( !arrayContains(groupedItems[hashKey].zones[zoneName], position) ) {
				arrayAppend(groupedItems[hashKey].zones[zoneName], position);
			}
		}

		return groupedItems;
	}
}
