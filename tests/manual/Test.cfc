component accessors="true"{

    property name="id" setter="false";
    property name="value" setter="false";

    public Test function init(){

        return this;
        
    }

    public Void function setId( value ) {

        variables.id = value;

    }

}
