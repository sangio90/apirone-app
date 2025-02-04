component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="product" type="com.apirone.core.model.bean.Product";
    property name="variant" type="com.apirone.core.model.bean.Variant";
    property name="color" type="com.apirone.core.model.bean.Color";
    property name="quantity" type="Numeric";

    public Component function init(){

        return this;
        
    }

}
