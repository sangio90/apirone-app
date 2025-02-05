component extends="com.apirone.core.model.bean.Component" accessors="true"{

    property name="line" type="com.apirone.core.model.bean.Line";
    property name="size" type="com.apirone.core.model.bean.Size";

    public ComponentLineSize function init(){

        return this;
        
    }

}
