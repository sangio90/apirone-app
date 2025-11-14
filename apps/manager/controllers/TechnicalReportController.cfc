component extends="com.apirone.core.controller.AbsController" {

	function print(event, rc, prc) {

		param rc.report = "quotation";
		var idPreventivo = rc.id;

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

		var zones = super.fire('QuotationZone.list', [ 'quotationId' = idPreventivo ]);
		quoteObj.zones = zones;

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

		for ( var i = 1; i LTE ArrayLen( zones ); i++ ) {
			var zone = zones[i];
			var zoneItems = super.fire('QuotationItem.list', [ 'quotationId' = idPreventivo, 'quotationZoneId' = zone.getId() ]);
			zone.zoneItems = zoneItems;
		}

		quoteObj.customerShippingAddress = customerShippingAddress;

		var saveAsName = "#rc.report#_#DateTimeFormat(Now(), 'yyyyMMdd-HHnnss')#.pdf";

		var params = {
			title   = "Preventivo",
			data    = quoteObj,
			pdfArgs = {
				bookmark          = true,
				backgroundVisible = true,
				orientation       = "portrait",
				pageType          = "A4",
				overwrite         = true,
				fontEmbed         = true,
				saveAsName        = "#rc.report#_#DateTimeFormat( Now(), "yyyyMMdd-HHnnss" )#.pdf"
			}
		}

		event.renderData( data = renderView( view = "report/template/#rc.report#", args = params ), type = "PDF" );
	}

}
