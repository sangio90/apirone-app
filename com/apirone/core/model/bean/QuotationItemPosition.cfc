component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationZone" type="com.apirone.core.model.bean.QuotationZone";
	property name="quotationItem" type="com.apirone.core.model.bean.QuotationItem";
	property name="positionCoordinateX" type="String";
	property name="positionCoordinateY" type="String";

	public QuotationItemPosition function init(){
		return this;
	}

}
