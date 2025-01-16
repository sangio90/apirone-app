component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="type" type="com.apirone.core.model.bean.ProductType";
    property name="processingType" type="com.apirone.core.model.bean.ProcessingType";
    property name="variants" type="com.apirone.core.model.bean.Variant[]";

    public Product function init(){

        return this;
        
    }

}
