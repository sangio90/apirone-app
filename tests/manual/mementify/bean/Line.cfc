component extends="BaseBean" accessors="true" {

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
