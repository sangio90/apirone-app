component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="componentId" type="Numeric";
    property name="productItemId" type="Numeric";

    property name="quantity" type="Numeric";
    property name="deleted" type="Boolean";

    public ComponentOverride function init(){

        this.setQuantity( 0 );
        this.setDeleted( false );
        
        return this;
        
    }
   
}
