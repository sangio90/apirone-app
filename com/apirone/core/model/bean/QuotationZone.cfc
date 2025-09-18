component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "name" ]
	}

	property name="quotation" type="com.apirone.core.model.bean.Quotation";
	property name="origin" type="com.apirone.core.model.bean.QuotationZone";

	public QuotationZone function init(){
		return this;
	}

}
