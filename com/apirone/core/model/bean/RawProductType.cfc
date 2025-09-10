component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name" ] }

	public RawProductType function init(){
		return this;
	}

}
