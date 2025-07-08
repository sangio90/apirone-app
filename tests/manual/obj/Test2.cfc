component accessors="true"{

    property name="id" default="1002";
    property name="value" default="myvalue2";

    this.name = "My name - this2";
    variables.name = "My name - variables2";

    public Test2 function init(){

        return this;
        
    }

    public Void function setId( value ) {

        variables.id = value;

    }

    public Void function writeId() {

        dump( "funziona: " & getId());

    }

}
