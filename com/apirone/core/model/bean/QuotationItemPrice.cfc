component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="quotationItemId" type="String";
	
	property name="amount" type="Numeric";
	property name="discount1" type="Numeric";
	property name="discount2" type="Numeric";

	property name="lines" type="com.apirone.core.model.bean.PriceLine[]";
	property name="method" type="com.apirone.core.model.bean.PriceMethod";

	public QuotationItemPrice function init(){
		var method = new com.apirone.core.model.bean.PriceMethod();

		// C = Calculated, F = fixed
		setMethod( method.setId( "C" ) );
		setLines( [] );

		return this;
	}

	public Numeric function getTotalGoods(){
		var total = 0;

		for ( var line in getLines() ) {
			total = total + line.getAmount();
		}

		return total;
	}

	public Numeric function getTotal(){
		var totalGoods = getTotalGoods();
		var total      = totalGoods;

		if ( isFixed() ) {
			return getAmount();
		}

		if ( StructKeyExists( variables, "discount1" ) && variables.discount1 > 0 ) {
			total = total - ( total * variables.discount1 / 100 );
		}

		if ( StructKeyExists( variables, "discount2" ) && variables.discount2 > 0 ) {
			total = total - ( total * variables.discount2 / 100 );
		}

		return total;
	}

	public Boolean function isFixed(){
		if ( getMethod().getId() == "F" ) {
			return true;
		}
		return false;
	}

}
