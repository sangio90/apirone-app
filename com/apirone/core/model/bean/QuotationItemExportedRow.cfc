component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"key",
			"rowNumber",
			"um",
			"code",
			"variant",
			"color",
			"quantity",
			"notes"
		]
	}

	property name="key" type="String";
	property name="rowNumber" type="Numeric";
	property name="code" type="String";
	property name="um" type="String";
	property name="variant" type="String";
	property name="color" type="String";
	property name="quantity" type="Numeric";
	property name="notes" type="String";

	public QuotationItemExportedRow function init(){
		return this;
	}
}
