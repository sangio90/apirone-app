component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationItemZone" type="com.apirone.core.model.bean.QuotationItemZone";
	property name="positionCoordinateX" type="String";
	property name="positionCoordinateY" type="String";

	public QuotationItemPosition function init(){
		return this;
	}
}
