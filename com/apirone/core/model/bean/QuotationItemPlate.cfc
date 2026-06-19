component extends="com.apirone.core.model.bean.QuotationItem" accessors="true" {

	property name="frame" type="com.apirone.core.model.bean.Frame";
	property name="fruits" type="com.apirone.core.model.bean.QuotationItemFruit[]";

	// override orientamento dei blocchi per questa riga, JSON {"<order>":"HOR|VER"}
	property name="blockOrientations" type="String";

	public QuotationItemPlate function init(){
		return this;
	}

}
