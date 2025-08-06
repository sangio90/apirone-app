component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="description" type="String";
	property name="quotationNumber" type="String";
	property name="versionNumber" type="Numeric";
	property name="quotationDate" type="Date";
	property name="notes" type="String";
	property name="validityDate" type="Date";
	property name="opportunityName" type="String";
	property name="leadName" type="String";
	property name="active" type="Numeric";
	property name="pricelist" type="com.apirone.core.model.bean.Pricelist";
	property name="paymentMethod" type="com.apirone.core.model.bean.PaymentMethod";
	property name="customPaymentMethod" type="String";
	property name="currency" type="com.apirone.core.model.bean.Currency";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="lang" type="com.apirone.core.model.bean.Lang";
	property name="billingProfile" type="com.apirone.core.model.bean.BillingProfile";
	property name="shippingProfile" type="com.apirone.core.model.bean.ShippingProfile";
	property name="salesAgentAccount" type="com.apirone.core.model.bean.Account";
	property name="graphicTechnicianAccount" type="com.apirone.core.model.bean.Account";

	public Quotation function init(){
		return this;
	}

}
