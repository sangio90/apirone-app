component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="level" type="Numeric";
    
    property name="attributeValue" type="com.apirone.core.model.bean.AttributeValue";
    property name="parent" type="com.apirone.core.model.bean.CombinationItem";

    public CombinationItem function init(){

        return this;
        
    }

}
