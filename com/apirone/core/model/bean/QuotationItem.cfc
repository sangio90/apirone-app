component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "price", "quantity" ],
		profiles = {
			edit = {
				defaultIncludes = [
					"id",
					"price",
					"quantity",
					"category",
					"finish",
					"line",
					"model",
					"font",
					"fontSize",
					"quotationZone",
					"signageRows"
				]
			}
		}
	}

	property name="price" type="Numeric";
	property name="quantity" type="Numeric";

	property name="quotation" type="com.apirone.core.model.bean.Quotation";
	property name="quotationZone" type="com.apirone.core.model.bean.QuotationZone";
	property name="product" type="com.apirone.core.model.bean.Product";

	public QuotationItem function init(){
		return this;
	}

}
