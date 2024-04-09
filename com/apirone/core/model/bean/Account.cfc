component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="login" type="String";
    property name="pwd" type="String";
    property name="apiKey" type="String";
    property name="status" type="com.apirone.core.model.bean.Status";
    property name="role" type="com.apirone.core.model.bean.Role";

    public Account function init(){

        return this;
    
    }

}
