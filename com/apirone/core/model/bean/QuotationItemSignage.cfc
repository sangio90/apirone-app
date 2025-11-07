component extends="com.apirone.core.model.bean.QuotationItem" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"price",
			"quantity",
			"shortId",
			"image"
		],
		profiles = {
			edit = {
				defaultIncludes = [
					"id",
					"price",
					"quantity",
					"product.finish",
					"quotationZone",
					"signageRows",
					"signageConfigItem"
				]
			}
		}
	}

	// campi storico signage per questa riga di preventivo. riprendiamo signage config item perché ha la stessa struttura.
	property name="signageConfigItem" type="com.apirone.core.model.bean.SignageConfigItem";
	property name="signageRows" type="com.apirone.core.model.bean.QuotationItemSignageRow[]";
	property name="image" type="com.apirone.core.model.bean.File";

	public QuotationItemSignage function init(){
		return this;
	}

}
