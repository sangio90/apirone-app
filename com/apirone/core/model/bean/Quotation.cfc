component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationNumber" type="String";
	property name="versionNumber" type="Numeric";
	property name="quotationDate" type="Date";
	property name="notes" type="String";
	property name="validityDate" type="Date";
	property name="active" type="Numeric";
	property name="pricelist" type="com.apirone.core.model.bean.Pricelist";
	property name="price" type="com.apirone.core.model.bean.QuotationPrice";
	property name="vatCode" type="com.apirone.core.model.bean.VatCode";
	property name="customer" type="com.apirone.core.model.bean.Customer";
	property name="customerAddressId" type="String";
	property name="opportunity" type="com.apirone.core.model.bean.Opportunity";
	property name="lead" type="com.apirone.core.model.bean.Lead";
	property name="paymentMethod" type="com.apirone.core.model.bean.PaymentMethod";
	property name="customPaymentMethod" type="String";
	property name="currency" type="com.apirone.core.model.bean.Currency";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="lang" type="com.apirone.core.model.bean.Lang";
	property name="billingProfile" type="com.apirone.core.model.bean.BillingProfile";
	property name="shippingProfile" type="com.apirone.core.model.bean.ShippingProfile";
	property name="salesAgentAccount" type="com.apirone.core.model.bean.Account";
	property name="graphicTechnicianAccount" type="com.apirone.core.model.bean.Account";
	property name="statusFile" type="com.apirone.core.model.bean.File";
	property name="calculatedAmount" type="Numeric";
	property name="serial" type="Numeric";
	property name="exported" type="Boolean";

	public Quotation function init(){
		return this;
	}

	public String function getDecodedPaymentMethod(){
		var paymentMethod = this.getPaymentMethod();
		if ( !IsNull( paymentMethod ) ) {
			return paymentMethod.getName();
		} else {
			return getCustomPaymentMethod();
		}
	}

}
