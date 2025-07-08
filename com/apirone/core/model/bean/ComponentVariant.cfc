component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="rawProduct" type="com.apirone.core.model.bean.RawProduct";
    property name="variant" type="com.apirone.core.model.bean.Variant";
    property name="color" type="com.apirone.core.model.bean.Color";
    property name="quantity" type="Numeric";

    //property name="baseQuantity" type="Numeric"; //from attributeValue

    property name="status" type="com.apirone.core.model.bean.Status";
    property name="typeId" type="String" default="own"; //own or base
    
    property name="variation" type="com.apirone.core.model.bean.ComponentVariation";

    public Component function init(){

        this.setBaseQuantity( 0 );
        return this;
        
    }
    
    public Numeric function getTotalQuantity(){

        return Val( this.getQuantity() + this.getBaseQuantity() );

    }

}
