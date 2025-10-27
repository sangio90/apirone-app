component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

	this.memento = {
		defaultIncludes = [ "id", "permission", "roleId", "active" ],
		profiles = {
			list = {
				defaultIncludes = [
					"id",
					"permission",
					"roleId",
					"active"
				]
			}
		}
	}

	property name="permission" type="com.apirone.core.model.bean.Permission";
	property name="roleId" type="String";
	property name="active" type="Boolean" default="false";

    public RolePermission function init(){

        return this;
    }

}
