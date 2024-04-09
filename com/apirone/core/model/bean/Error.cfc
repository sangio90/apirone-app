component accessors="true" extends="com.apirone.core.model.bean.AbsBean" {

    property name="type" type="String" default="";
    property name="message" type="String" default="";

    public com.apirone.core.model.bean.Error function init(){
        return this;
    }

}
