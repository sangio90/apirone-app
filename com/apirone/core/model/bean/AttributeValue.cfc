component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true"{

    property name="orderBy" type="Numeric" default=10;
    property name="status" type="com.apirone.core.model.bean.Status";
    property name="rawValue" type="com.apirone.core.model.bean.RawValue";
    
    property name="attributeId" type="String";
    property name="componentCount" type="Numeric";

    //NOTE: Attribute ha già AttributeValue all'interno,
    //questo crea una ricorsione: StackOverflow
    //property name="attribute" type="com.apirone.core.model.bean.Attribute";

    public AttributeValue function init(){

        return this;
        
    }

}
