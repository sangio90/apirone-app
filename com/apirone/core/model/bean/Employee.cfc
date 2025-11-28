component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="surname" type="String";
    property name="fiscalCode" type="String";
    property name="phone" type="String";
    property name="wallet" type="com.apirone.core.model.bean.Wallet";
    property name="status" type="com.apirone.core.model.bean.Status";
    property name="account" type="com.apirone.core.model.bean.Account";
    property name="location" type="com.apirone.core.model.bean.Location";

    public Employee function init(){

        return this;
    }

}
