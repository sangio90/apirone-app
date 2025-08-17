component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {
    /* 
        ATTENTION:
        i dont want to extend this bean 
    */

	//{ "key" = "value" } - es. { "attribute.id" = "COLOR" }
    property name="key";
    property name="value";    

    public com.apirone.core.model.bean.Entity function init(){
        
        return this;
    
    }

    public Struct function getMemento(){

        var obj = new com.apirone.core.model.bean.AbsBean()
        
        return obj.getMemento( this );
    
    }

    public Struct function setMemento( data ){

        var obj = new com.apirone.core.model.bean.AbsBean()
        
        return obj.setMemento( data, getMetaData( this ) );
    
    }

}
