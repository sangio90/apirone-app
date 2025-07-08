component accessors="true"{

    property name="id" default="100";
    property name="value" default="myvalue";
    property name="test2" type="Test2";

    this.name = "My name - this";
    variables.name = "My name - variables";

    public Test function init(){

        //setTest2( new Test2() );

        return this;
        
    }

    public Void function setId( value ) {

        variables.id = value;

    }

    public Void function writeId() {

        dump( "funziona: " & getId());

    }

    public Void function writeName() {

        dump( "funziona: " & variables.name );

    }

    public Void function writeValue() {

        dump( "funziona: " & this.getValue() );

    }

}
