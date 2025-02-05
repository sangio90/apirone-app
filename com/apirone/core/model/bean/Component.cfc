component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="product" type="com.apirone.core.model.bean.Product";
    property name="variant" type="com.apirone.core.model.bean.Variant";
    property name="color" type="com.apirone.core.model.bean.Color";
    property name="quantity" type="Numeric";

    property name="status" type="com.apirone.core.model.bean.Status";

    public Component function init(){

        return this;
        
    }

}
