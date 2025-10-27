component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

	this.memento = {
		defaultIncludes = [ "id", "name", "permissions" ],
	}

	property name="permissions" type="com.apirone.core.model.bean.RolePermission[]";

    public Role function init(){

        return this;
    }

}
