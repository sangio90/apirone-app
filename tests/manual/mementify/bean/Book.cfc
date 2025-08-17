component extends="BaseBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "name" ] }

	property name="level" type="Numeric" default="#RandRange( 1, 99 )#";

	public Book function init(){
		return this;
	}

}
