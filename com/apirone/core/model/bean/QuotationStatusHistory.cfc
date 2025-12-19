component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {
	
	property name="quotationId" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="user" type="com.apirone.core.model.bean.User";
	property name="file" type="com.apirone.core.model.bean.File";

	public QuotationStatusHistory function init(){
		return this;
	}

}
