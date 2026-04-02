component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

    property name="counter" type="String";
    property name="productHashId" type="Numeric";

	public ExportCode function init(){
		return this;
	}

}
