component extends="com.apirone.core.model.bean.Component" accessors="true"{

    property name="product" type="com.apirone.core.model.bean.Product";
    
    public ComponentProduct function init(){

        return this;
        
    }

	public Struct function extractIds(){
		return { "id": getId(), "productId": getProduct().getId() };
	}

}
