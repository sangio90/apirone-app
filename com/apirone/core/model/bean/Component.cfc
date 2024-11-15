component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="type" type="com.apirone.core.model.bean.ComponentType";
    property name="colors" type="com.apirone.core.model.bean.Color[]";
    property name="variants" type="com.apirone.core.model.bean.Variant[]";

    public Component function init(){

        return this;
        
    }

}
