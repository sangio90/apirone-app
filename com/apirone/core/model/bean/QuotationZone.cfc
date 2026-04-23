component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	//TODO: remove this reference form an quotationId
	property name="quotation" type="com.apirone.core.model.bean.Quotation"; 
	property name="quantity" type="numeric"; 
	property name="origin" type="com.apirone.core.model.bean.QuotationZone";
	property name="image" type="com.apirone.core.model.bean.File";

	public QuotationZone function init(){
		return this;
	}

}
