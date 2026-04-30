component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationItemId" type="String";
	property name="coordinateX" type="Numeric";
	property name="coordinateY" type="Numeric";
	property name="sequence" type="Numeric";
	property name="angle" type="Numeric" default="0";
	property name="visible" type="Boolean" default="false";

	public QuotationItemPosition function init(){
		return this;
	}

}
