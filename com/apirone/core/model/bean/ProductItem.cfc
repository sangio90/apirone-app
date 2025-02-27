component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="level" type="Numeric";
    property name="orderBy" type="String";
    property name="combinationId" type="String";
    
    property name="status" type="com.apirone.core.model.bean.Status";
    property name="parent" type="com.apirone.core.model.bean.ProductItem"; //TODO: is this usefull?
    property name="attributeValue" type="com.apirone.core.model.bean.AttributeValue";
    property name="attribute" type="com.apirone.core.model.bean.Attribute";
    
    public ProductItem function init(){

        return this;
        
    }

}
