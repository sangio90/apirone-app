component accessors="true"{

    property name="id" default="100" setter=false getter=false;
    property name="value" default="myvalue";
    property name="test2" type="Test2";

    this.name = "My name - this";
    variables.name = "My name - variables";

    public Test function init(){

        return this;
        
    }

    public Numeric function writeId( value ) {

        variables.id = "200"

        return variables.id;

    }

}
