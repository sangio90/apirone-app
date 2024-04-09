component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="status" type="Boolean" default="false";
    property name="account" type="com.apirone.core.model.bean.Account";
    property name="error" type="com.apirone.core.model.bean.Error";

    public LoginResult function init(){

        return this;
    
    }

}