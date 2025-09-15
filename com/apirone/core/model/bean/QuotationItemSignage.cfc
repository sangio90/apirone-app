component extends="com.apirone.core.model.bean.QuotationItem" accessors="true" {

	//campi storico signage per questa riga di preventivo. riprendiamo signage config item perché ha la stessa struttura.
	property name="signageConfigItem" type="com.apirone.core.model.bean.SignageConfigItem";
	property name="signageRows" type="com.apirone.core.model.bean.QuotationItemSignageRow[]";

	public QuotationItemSignage function init(){
		return this;
	}
}
