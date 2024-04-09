component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="message" type="String" default="Not Authorized";
    property name="status" type="String" default="NOT_AUTH";

    public ApiLogin function init(){

        return this;
    }

}
