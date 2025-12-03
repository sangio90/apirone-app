component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {
	
	this.memento = {
		defaultIncludes = [ "id", "shortId", "quotationId", "status", "account", "file", "createdAt" ]
	}

	property name="quotationId" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="account" type="com.apirone.core.model.bean.Account";
	property name="file" type="com.apirone.core.model.bean.File";

	public QuotationStatusHistory function init(){
		return this;
	}

}
