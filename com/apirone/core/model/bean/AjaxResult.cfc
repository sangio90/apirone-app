component accessors="true" {

    property name="uuid" type="String";
    property name="status" type="String";
    property name="count" type="Numeric" default="1"; //numero di record del set
    property name="total" type="Numeric" default="1"; //numero di record totali
    property name="data";

    public AjaxResult function init(){

        return this;
    
    }

	public Struct function toStruct(){
		
		return DESerializeJSON( SerializeJSON( this ) );
		
	}    

}