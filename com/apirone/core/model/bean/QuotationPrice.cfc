component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="items" type="com.apirone.core.model.bean.PriceItem[]";
	property name="price" type="com.apirone.core.model.bean.Price";

	property name="discount1" type="Numeric";
	property name="discount2" type="Numeric";
	property name="fixedPrice" type="Numeric";

	public QuotationPrice function init(){
		return this;
	}

	public Numeric function getTotalGoods(){
		var total = 0;

		for ( var item in getItems() ) {
			total = +item.getAmount();
		}

		return total;
	}

	public Numeric function getTotalPrice(){
		var totalGoods = getTotalGoods();
		var total      = totalGoods;

		if ( StructKeyExists( variables, "discount1" ) && variables.discount1 > 0 ) {
			total = total - ( total * variables.discount1 / 100 );
		}

		if ( StructKeyExists( variables, "discount2" ) && variables.discount2 > 0 ) {
			total = total - ( total * variables.discount2 / 100 );
		}

		if ( StructKeyExists( variables, "fixedPrice" ) && variables.fixedPrice > 0 ) {
			total = variables.fixedPrice;
		}

		return total;
	}

}
