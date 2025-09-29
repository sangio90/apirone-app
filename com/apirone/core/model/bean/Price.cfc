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
    property name="type" type="com.apirone.core.model.bean.PriceType";
    property name="method" type="com.apirone.core.model.bean.PriceMethod";
    property name="status" type="com.apirone.core.model.bean.Status";
    property name="entity" type="com.apirone.core.model.bean.Entity";

    public Price function init(){

        return this;
    }

    public Numeric function getFinalPrice() {

        return getAmount()

    }

}
