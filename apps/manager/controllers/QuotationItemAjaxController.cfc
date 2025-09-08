component extends="com.apirone.core.controller.AbsController" {
	function save( event, rc, prc ){
        var json = DeserializeJSON(GetHTTPRequestData().content);

		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var result = super.getResult();

		var quotationItemSignageBean = super.bean('QuotationItemSignage');

		quotationItemSignageBean.setSignage(super.service( "SignageConfigItem" ).get( json.signageConfigItem.id ));
		quotationItemSignageBean.getSignage().setCharCount(json.fontSize.charCount);
		quotationItemSignageBean.setHeight(json.fontSize.height);
		quotationItemSignageBean.setHeightInPixel(json.fontSize.heightInPixels);
		quotationItemSignageBean.setRowCount(json.fontSize.rowCount);
		quotationItemSignageBean.setPrice(20.1);
		quotationItemSignageBean.setQuantity(2);
		if ( !Len( json.id ) ) {
			messageId = "quotationItem.created";
			thisId    = super.fire( "quotationItem.create", [ quotationItemSignageBean ] )
		} else {
			messageId = "quotationItem.updated";
			thisId    = super.fire( "quotationItem.update", [ quotationItemSignageBean ] )
		}
	
		for (signageLine in json.signageLines._data) {
			var signageLine = super.bean('QuotationItemSignageRow')
			signageLine.setQuotationItem(quotationItemSignageBean);
			signageLine.setTextAlign(signageLine.textAlign);
			signageLine.setContent(signageLine.content);
			signageLine.setOrderby(signageLine.orderby);
			signageLine.setCharCount(signageLine.charCount);

			if (!signageLine.id) {
				super.fire( "QuotationItemSignageRow.create", [signageLine] );
			} else {
				super.fire( "QuotationItemSignageRow.update", [signageLine] );
			}
		}
		
		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}
}