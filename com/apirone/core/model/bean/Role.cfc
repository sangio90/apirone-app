component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    
    property name="type" type="com.apirone.core.model.bean.RoleType";
	property name="permissions" type="com.apirone.core.model.bean.RolePermission[]";

	property name="minQuantity" type="Numeric";
	property name="maxQuantity" type="Numeric";
	property name="quotationMaxAmount" type="Numeric";
	property name="quotationMaxDiscount" type="Numeric";

    public Role function init(){

        return this;
    }

}
