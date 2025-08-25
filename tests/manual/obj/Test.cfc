component accessors="true" {

	property name="textValue" type="String" getter="false" setter="false";
	property name="booleanValue" type="Boolean" getter="false" setter="false";
	property name="integerValue" type="Numeric" getter="false" setter="false";
	property name="decimalValue" type="Numeric" getter="false" setter="false";

    variables.type="BOOLEAN";

	public Test function init(){
		return this;
	}

	public Any function getValue(){
		switch ( variables.type ) {
			case "BOOLEAN":
				dump( variables.textValue );
				dump( getbooleanValue() );
				abort;
				return variables.booleanValue;
			case "INTEGER":
				return variables.integerValue;
			case "DECIMAL":
				return variables.decimalValue;
			case "TEXT":
				return variables.textValue;
			default:
				Throw(
					type    = "apirone.error.metadata.DataTypeNotSupported",
					message = "The [#getType().getDataType().getId()#] data type is not supported."
				)
		}
	}

	public Any function setValue( required Any value ){
		switch ( UCase( getType().getDataType().getId() ) ) {
			case "BOOLEAN":
				variables.booleanValue = arguments.value;
				break;
			case "INTEGER":
				variables.integerValue = arguments.value;
				break;
			case "DECIMAL":
				variables.decimalValue = arguments.value;
				break;
			case "TEXT":
				variables.textValue = arguments.value;
				break;
			default:
				Throw(
					type    = "apirone.error.metadata.dataTypeNotSupported",
					message = "The [#getType().getDataType().getId()#] data type is not supported."
				)
		}
	}

}
