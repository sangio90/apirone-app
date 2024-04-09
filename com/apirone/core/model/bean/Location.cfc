component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="address" type="String";
    property name="city" type="com.apirone.core.model.bean.City";
    property name="postalCode" type="String";

    public Location function init(){

        return this;
    }

}
