component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="texts" type="com.apirone.core.model.bean.Text[]";
    property name="status" type="com.apirone.core.model.bean.Status";
    property name="orderBy" type="Numeric" default=10;
    
    property name="attributeId" type="String";

    public AttributeValue function init(){

        return this;
        
    }

}
