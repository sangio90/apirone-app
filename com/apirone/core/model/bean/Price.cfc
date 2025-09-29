component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

	this.memento = {
		defaultIncludes = [
			"id",
			"type",
			"method",
			"amount",
		]
	}    

    property name="amount" type="Numeric";
    property name="type" type="String" hint='com.apirone.core.model.bean.PriceType';
    property name="method" type="String" hint='com.apirone.core.model.bean.PriceMethod';

    public Price function init(){

        return this;
    }

    public Numeric function getFinalPrice() {

        return getAmount()

    }

}
