component accessors="true" {

    property name="uuid" type="String";
    property name="status" type="String";
    property name="count" type="Numeric"; //numero di record della pagina
    property name="total" type="Numeric"; //numero di record totali
    property name="data";

    public AjaxResult function init(){

        setTotal( 1 ) //better format here, instead of "default";
        setCount( 1 );

        return this;
    
    }

	public Struct function toStruct(){
		
		return DESerializeJSON( SerializeJSON( this ) );
		
	}    

}