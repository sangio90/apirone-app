component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	//testa
	property name="key" type="String";
	property name="company" type="String";
	property name="quotationSerial" type="String";
	property name="quotationCode" type="String";
	property name="billingStreet" type="String";
	property name="billingCity" type="String";
	property name="billingState" type="String";
	property name="billingCountry" type="String";
	property name="vatNumber" type="String";
	property name="shippingStreet" type="String";
	property name="shippingCity" type="String";
	property name="shippingState" type="String";
	property name="shippingCountry" type="String";
	property name="shippingDate" type="Date";
	property name="opportunity" type="String";
	property name="pricelist" type="String";
	property name="agent" type="String";
	property name="notes" type="String";

	//riga
	property name="rowNumber" type="Numeric";
	property name="productCode" type="String";
	property name="variantCode" type="String";
	property name="colorCode" type="String";
	property name="um" type="String";
	property name="quantity" type="Numeric";
	property name="price" type="Numeric";
	property name="discount1" type="Numeric";
	property name="discount2" type="Numeric";

	public QuotationExported function init(){
		return this;
	}
	
	public String function getBillingAddress(){
		return getBillingStreet() & " " & getBillingCity() & " " & getBillingState() & " " & getBillingCountry();
	}

	public String function getShippingProfile(){
		return getShippingStreet() & " " & getShippingCity() & " " & getShippingState() & " " & getShippingCountry();
	}

}
