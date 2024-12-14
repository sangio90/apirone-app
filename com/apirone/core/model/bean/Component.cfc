component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="type" type="com.apirone.core.model.bean.ComponentType";
    property name="processingType" type="com.apirone.core.model.bean.ProcessingType";
    property name="variants" type="com.apirone.core.model.bean.Variant[]";
    //property name="colors" type="com.apirone.core.model.bean.Color[]";

    public Component function init(){

        return this;
        
    }

}
