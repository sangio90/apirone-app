component accessors="true" extends="AbsBean" {

	property name="role" type="com.apirone.core.model.bean.Role";
	property name="account" type="com.apirone.core.model.bean.Account";
			
	public User function init(){

		setId( "ANONYMOUS" );

		return this;

	}

	public Boolean function isLogged(){

		return getId() != "ANONYMOUS";

	}

}
