component extends="BaseBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name" ] }

	public Category function init(){
		return this;
	}

}
