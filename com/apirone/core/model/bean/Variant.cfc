component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="type" type="com.apirone.core.model.bean.ComponentType";
    //property name="attributes" type="com.apirone.core.model.bean.Attribute[]";
    property name="colors" type="com.apirone.core.model.bean.Color[]";

    public ComponentType function init(){

        return this;
        
    }

}
