component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name", "code" ] }

	public DataType function init(){
		return this;
	}

}
