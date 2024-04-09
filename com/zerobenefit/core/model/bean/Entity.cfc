component accessors="true" extends="com.apirone.core.model.bean.AbsBean" {

    property name="type" type="String" default="";

    public com.apirone.core.model.bean.Entity function init(){
        return this;
    }

}
