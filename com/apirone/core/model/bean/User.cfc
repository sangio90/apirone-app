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

	public boolean function canDo( required string permissionId ){
		if ( getRole().getId() == "ADM" ) {
			return true;
		}
		var rolePermissions = getRole().getPermissions();
		for ( var rolePermission in rolePermissions ) {
			if ( rolePermission.getPermission().getId() == permissionId ) {
				return true;
			}
		}
		return false;
	}

}
