component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="level" type="Numeric";
    property name="orderBy" type="String";
    property name="combinationId" type="String";
    property name="productItem" type="com.apirone.core.model.bean.ProductItem";
    
    public ProductItemCombination function init(){

        return this;
        
    }

}
