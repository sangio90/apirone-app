component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = { defaultIncludes = [ "id", "code", "value", "type" ] }

	property name="code" type="String";
	property name="createdAt" type="Date";

	property name="type" type="com.apirone.core.model.bean.MetadataType";
	property name="entity" type="com.apirone.core.model.bean.Entity";

	/*
	property name="textValue" type="String" getter="false" setter="false";
	property name="booleanValue" type="Boolean" getter="false" setter="false";
	property name="integerValue" type="Numeric" getter="false" setter="false";
	property name="decimalValue" type="Numeric" getter="false" setter="false";
	*/

	variables.textValue    = NullValue();
	variables.booleanValue = NullValue();
	variables.integerValue = NullValue();
	variables.decimalValue = NullValue();

	public Metadata function init(){
		return this;
	}

	public Any function getValue(){
		switch ( UCase( getType().getDataType().getId() ) ) {
			case "BOOLEAN":
				return variables.booleanValue;
			case "INTEGER":
				return variables.integerValue;
			case "DECIMAL":
				return variables.decimalValue;
			case "STRING":
			case "TEXT":
				return variables.textValue;
			default:
				Throw(
					type    = "apirone.error.metadata.DataTypeNotSupported",
					message = "The [#getType().getDataType().getId()#] dataType is not supported."
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
			case "STRING":
			case "TEXT":
				variables.textValue = arguments.value;
				break;
			default:
				Throw(
					type    = "apirone.error.metadata.dataTypeNotSupported",
					message = "The [#getType().getDataType().getId()#] dataType is not supported."
				)
		}
	}

	public String function getDataTypeId(){
		return getType().getDataType().getId()
	}

}
