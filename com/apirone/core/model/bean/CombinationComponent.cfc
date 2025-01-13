component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="component" type="com.apirone.core.model.bean.Component";
    //property name="size" type="com.apirone.core.model.bean.Size";
    property name="variant" type="com.apirone.core.model.bean.Variant";
    property name="color" type="com.apirone.core.model.bean.Color";
    property name="quantity" type="Numeric";

    public CombinationComponent function init(){

        return this;
        
    }

}
