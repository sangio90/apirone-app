component extends="com.apirone.core.model.bean.Component" accessors="true"{

    property name="attributeValue" type="com.apirone.core.model.bean.AttributeValue";
    property name="baseQuantity" type="Numeric"; //from attributeValue
    
    public ComponentAttributeValue function init(){

        this.setBaseQuantity( 0 );
        this.setTypeId( "base" );

        return this;
        
    }
    
    public Numeric function getTotalQuantity(){

        return Val( this.getQuantity() + this.getBaseQuantity() );

    }

	public Struct function extractIds(){
		return { "id": getId(), "attributeValueId": getAttributeValue().getId() };
	}

}
