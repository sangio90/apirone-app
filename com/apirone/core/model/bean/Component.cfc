component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"rawProduct",
			"variant",
			"color",
			"quantity",
			"typeId",
			"cost"
		],
		profiles = {
			list = {
				defaultIncludes = [
					"id",
					"shortId",
					"rawProduct",
					"variant",
					"color",
					"quantity",
					"override",
					"status",
					"typeId",
					"totalQuantity",
					"cost",
					"kindId"
				]
			}
		}
	}

	property name="rawProduct" type="com.apirone.core.model.bean.RawProduct"; // arriva da Verticale
	property name="variant" type="com.apirone.core.model.bean.Variant"; // arriva da Verticale
	property name="color" type="com.apirone.core.model.bean.Color"; // arriva da Verticale
	property name="cost" type="com.apirone.core.model.bean.Cost"; // arriva da Verticale

	property name="quantity" type="Numeric";

	property name="override" type="com.apirone.core.model.bean.ComponentOverride";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="typeId" type="String" default="own"; // own or base
	property name="kindId" type="String" default=""; // ** usare cum grano salis **

	public Component function init(){
		var cost = new com.apirone.core.model.bean.Cost();

		setCost( cost );

		return this;
	}

	public Numeric function getTotalQuantity(){
		if ( IsNull( this.getOverride() ) ) {
			return this.getQuantity();
		}

		return Val( this.getQuantity() ) + Val( this.getOverride().getQuantity() );
	}

}
