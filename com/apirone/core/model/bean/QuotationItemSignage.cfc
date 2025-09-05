component extends="com.apirone.core.model.bean.QuotationItem" accessors="true" {

	//campi storico signage per questa riga di preventivo. riprendiamo signage config item perché ha la stessa struttura.
	property name="signage" type="com.apirone.core.model.bean.SignageConfigItem";
	property name="rows" type="com.apirone.core.model.bean.QuotationItemSignageRow[]";

	public QuotationItem function init(){
		return this;
	}

}
