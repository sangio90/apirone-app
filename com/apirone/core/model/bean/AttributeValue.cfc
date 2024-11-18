component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true"{

    property name="code" type="String";
    property name="orderBy" type="Numeric" default=10;
    property name="status" type="com.apirone.core.model.bean.Status";
    
    property name="attributeId" type="String";

    public AttributeValue function init(){

        return this;
        
    }

}
