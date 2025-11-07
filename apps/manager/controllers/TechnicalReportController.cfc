component extends="com.apirone.core.controller.AbsController" {

	function print(){
		prc.title = "Placche";
		var mem = super.getMementify();

		dump("remmove abort");
		abort;

		var quotations = service("Quotation").list(limit=2);

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

		var body = {
			"token"   = "FIXED_TOKEN",
			"jxml"    = "placche.jxml",
			"payload" = quoteObj
		}

		var tempFile = getTempFile( getTempDirectory(), "file_#CreateUUID()#.pdf" );

		cfhttp( url="reportingUrl?activePrice=1", result="pdfReport", file=tempFile, method="post" ) {
			cfhttpparam(type="header", name="Content-Type", value="application/json");
			cfhttpparam(type="body", value="#SerializeJSON( body )#");
		}

		cfheader( name="Content-Disposition", value="attachment; filename=pdfReport.pdf" );
		cfcontent( file=tempFile, type="application/pdf" );

		return false;

	}

}
