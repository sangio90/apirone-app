component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationItemId" type="String";
	property name="coordinateX" type="Numeric";
	property name="coordinateY" type="Numeric";
	property name="sequence" type="Numeric";

	public QuotationItemPosition function init(){
		return this;
	}

}
