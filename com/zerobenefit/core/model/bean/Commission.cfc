component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="value" type="Numeric";
    property name="category" type="com.apirone.core.model.bean.ProductCategory";

    public Commission function init(){

        return this;
    
    }

}
