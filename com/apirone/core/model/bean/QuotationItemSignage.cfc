component extends="com.apirone.core.model.bean.QuotationItem" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "price", "quantity", "shortId", "height", "heightInPixel", "charCount", "rowCount" ]
		,
		profiles = {
			edit = {
				defaultIncludes = [
					"id",
					"price",
					"quantity",
					"height",
					"heightInPixel",
					"charCount",
					"rowCount",
					"product",
					"font",
					"fontSize",
					"quotationZone",
					"signageRows",
					"signageConfigItem"
				]
			}
		}
	}
	
	//campi storico signage per questa riga di preventivo. riprendiamo signage config item perché ha la stessa struttura.
	property name="signageConfigItem" type="com.apirone.core.model.bean.SignageConfigItem";
	property name="signageRows" type="com.apirone.core.model.bean.QuotationItemSignageRow[]";

	public QuotationItemSignage function init(){
		return this;
	}
}
