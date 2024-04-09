component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{
    
    property name="productId" type="String";
    property name="description" type="String";
    property name="weight" type="Numeric" default="0";
    property name="availableQuantity" type="Numeric" default="0";

    property name="status" type="com.apirone.core.model.bean.Status";
    property name="price" type="com.apirone.core.model.bean.Price";
    property name="images" type="com.apirone.core.model.bean.File[]";

    public ProductVariant function init(){

        return this;
    
    }

}