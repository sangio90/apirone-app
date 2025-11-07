component extends="com.apirone.core.controller.AbsController" {

	function print( event, rc, prc ){

		dump("print");
		abort;

		param rc.report = "quotation";

		prc.title = "Preventivo";

		var memy = super.getMementify();

		var searchArgs = {};
		var filters    = {};

		for( var quote in quotations ) {
			var itemsData = [];
			var quoteObj = mem.convert( quote, "detail" ) //struct

			var items = service("QuotationItem").list( quotationId=quote.id ); 
			
			for( item in items ) {
				var itemObj = mem.convert( item, "detail" ) //struct
				itemsData.append( itemObj );
			}

			quoteObj["items"] = itemsData;

		}
	
		var params = {
			title   = "Preventivo",
			filters = filters,
			data    = quoteObj,
			pdfArgs = {
				bookmark          = true,
				backgroundVisible = true,
				orientation       = "landscape",
				pageType          = "A4",
				overwrite         = true,
				fontEmbed         = true,
				saveAsName        = "#rc.report#_#DateTimeFormat( Now(), "yyyyMMdd-HHnnss" )#.pdf"
			}
		}

		event.renderData( data = renderView( view = "report/template/#rc.report#", args = params ), type = "PDF" );
	}

}
