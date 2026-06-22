component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationId"     type="String";
	property name="quotationZoneId" type="String";
	property name="itemType"        type="String";
	property name="coordinateX"     type="Numeric";
	property name="coordinateY"     type="Numeric";
	property name="angle"           type="Numeric" default="0";
	property name="createdAt"       type="String";

	public QuotationItemDraft function init() {
		return this;
	}

}
