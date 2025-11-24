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

		var zones = super.fire('QuotationZone.list', [ 'quotationId' = idPreventivo, 'orderby' = [ { field = "quotationItemZone.originId", dir = "desc" } ] ]);
		
		var sortedZones = [];
		for (var zone in zones) {
			if (isNull(zone.getOrigin())) {
				sortedZones.add(zone)
				var subZones = super.fire('QuotationZone.list', [ 'quotationId' = idPreventivo, 'originId' = zone.getId() ])
				for ( var subZone in subZones ) {
					sortedZones.add(subZone)
				}
			}
		}

		var customerShippingAddress = [
			'name' = null,
			'via' = null,
			'cap' = null,
			'citta' = null,
			'provincia' = null,
			'paese' = null
		];
		if (!isNull(quotation.getCustomer().getShippingAddresses()) && quotation.getCustomer().getShippingAddresses().length > 0) {
			customerShippingAddress = quotation.getCustomer().getShippingAddresses()[1];
		}

		for ( var i = 1; i LTE ArrayLen( sortedZones ); i++ ) {
			var zone = sortedZones[i];
			if (printParams.grouped) {
				if (!isNull((zone.getOrigin()))) {
					continue;
				}
				var zoneItems = super.fire('QuotationItem.list', [ 'quotationId' = idPreventivo, 'quotationZoneId' = zone.getId() ]);
				var subZones = zones.filter(function(item) {
					return !isNull(item.getOrigin()) && item.getOrigin().getId() == zone.getId()
				})
				for ( var subZone in subZones ) {
					var thisSubZoneItems = super.fire('QuotationItem.list', [ 'quotationId' = idPreventivo, 'quotationZoneId' = subZone.getId() ]);
					arrayAppend(zoneItems, thisSubZoneItems, true);
				}
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

		quoteObj.customerShippingAddress = customerShippingAddress;

		var saveAsName = "print-quotation-#printParams.report#_#DateTimeFormat(Now(), 'yyyyMMdd-HHnnss')#.pdf";

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
				saveAsName        = "#printParams.report#_#DateTimeFormat( Now(), "yyyyMMdd-HHnnss" )#.pdf"
			}
		}

		event.renderData( data = renderView( view = "report/template/print-quotation-#rc.report#", args = params ), type = "PDF" );
	}

}
