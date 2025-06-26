component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true"{

    property name="status" type="com.apirone.core.model.bean.Status";
    property name="values" type="com.apirone.core.model.bean.AttributeValue[]";
    property name="categories" type="com.apirone.core.model.bean.ProductCategory[]";
    
    property name="code" type="String";

    public Attribute function init(){

        return this;
        
    }

}
