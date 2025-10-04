component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "amount", "type", "method", "amount" ]
	}

	property name="amount" type="Numeric";

	public Cost function init(){
		setAmount( 0 );

		return this;
	}

}
