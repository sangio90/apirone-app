component extends="com.apirone.core.model.bean.Component" accessors="true"{

    property name="productItem" type="com.apirone.core.model.bean.ProductItem";
    //property name="baseQuantity" type="Numeric"; //from attributeValue
    
    public ComponentProductItem function init(){

        //this.setBaseQuantity( 0 );
        //this.setTypeId( "base" );

        return this;
        
    }
    
    /*
    public Numeric function getTotalQuantity(){

        return Val( this.getQuantity() + this.getBaseQuantity() );

    }
    */


}
