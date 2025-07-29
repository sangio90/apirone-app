component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	property name="quotationDescription" type="String";
	property name="quotationNumber" type="String";
	property name="quotationLanguage" type="String";
	property name="quotationDate" type="Date";
	property name="note" type="String";
	property name="validityDate" type="Date";
	property name="opportunityName" type="String";
	property name="leadName" type="String";
	property name="pricelist" type="String";
	property name="paymentMethod" type="String";
	property name="customPaymentMethod" type="String";
	property name="currency" type="String";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="lang" type="com.apirone.core.model.bean.Language";
	property name="billingProfile" type="com.apirone.core.model.bean.Profile";
	property name="shippingProfile" type="com.apirone.core.model.bean.Profile";
	property name="salesAgentAccount" type="com.apirone.core.model.bean.Account";
	property name="graphicTechnicianAccount" type="com.apirone.core.model.bean.Account";

	public Quotation function init(){
		return this;
	}

}
