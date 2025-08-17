component extends="BaseBean" accessors="true" {

	this.memento = {
		defaultIncludes  = [ "id", "code" ],
		defaultExcludes  = [],
		neverInclude     = [ "name" ],
		defaults         = {},
		mappers          = {},
		profiles         = { list = { defaultIncludes = [ "name", "id", "book.level", "createdAt", "gone" ] } }
	}

	property name="code" type="String";
	property name="thisDate" type="String" default="#Now()#";
	property name="status" type="Status";
	property name="book" type="Book";
	property name="gone" type="Boolean";
	property name="categories" type="Category[]";

	public Line function init(){
		return this;
	}

}
