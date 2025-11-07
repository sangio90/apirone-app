component extends="com.apirone.core.controller.AbsController" {

	function print(){
		prc.title = "Placche";
		var mem = super.getMementify();

		var quotations = service("Quotation").list(limit=2);

		for( quote in quotations ) {
			var itemsData = [];
			var quoteObj = mem.convert( quote, "detail" ) //struct

			var items = service("QuotationItem").list( quotationId=quote.id ); 
			
			for( item in items ) {
				var itemObj = mem.convert( item, "detail" ) //struct
				itemsData.append( itemObj );
			}

			quoteObj["items"] = itemsData;

		}

		var body = {
			"token"   = "FIXED_TOKEN",
			"jxml"    = "placche.jxml",
			"payload" = quoteObj
		}

		cfhttp( url="reportingUrl?activePrice=1",) {
			cfhttpparam(type="header", name="Content-Type", value="application/json");
			cfhttpparam(type="body", value="#SerializeJSON( body )#");
		}

		return false;

	}

}
