component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="price" type="Numeric";
    property name="quantity" type="Numeric";

    property name="status" type="com.apirone.core.model.bean.Status";
    property name="rawProduct" type="com.apirone.core.model.bean.RawProduct";
    property name="productVariant" type="com.apirone.core.model.bean.RawProductVariant";
    
    public DocumentItem function init(){

        return this;
        
    }

}
