component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="price" type="Numeric" default="0";
    property name="quantity" type="Numeric" default="0";
    
    property name="product" type="com.apirone.core.model.bean.Product";
    property name="variant" type="com.apirone.core.model.bean.ProductVariant";
    
    public CartItem function init(){

        return this;
        
    }

}
