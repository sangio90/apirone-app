component accessors="true" extends="com.apirone.core.model.bean.AbsBean" {

	property name="created" type="Date" default="#Now()#";
	property name="status" type="String" default="SUCCESS";
	property name="error";
	property name="message" type="String";
	property name="type" type="String"; // Tipo-di-errore
	property name="data";

	public Outcome function init(){
		return this;
	}

	public Boolean function hasError(){
		return getStatus() == "ERROR";
	}

}