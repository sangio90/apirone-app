component accessors="true" {

    property name="count" type="Numeric"; //numero di record del set
    property name="total" type="Numeric" default="-1"; //numero di record totali
    property name="data";

    public Result function init(){

        return this;
    
    }

}