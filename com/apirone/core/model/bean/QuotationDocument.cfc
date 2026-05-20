component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationId"  type="String";
	property name="originalName" type="String";
	property name="storedName"   type="String";
	property name="directory"    type="String";
	property name="sortOrder"    type="Numeric";
	property name="createdAt";

	public QuotationDocument function init(){
		return this;
	}

	public String function getUri(){
		var settings = new config.Settings();
		return settings.get( "site.repository" ) & "/media/quotation-documents/" & getDirectory() & "/" & getStoredName();
	}

}
