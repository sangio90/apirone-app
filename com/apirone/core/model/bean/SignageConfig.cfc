component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="font" type="com.apirone.core.model.bean.Font";
    property name="item" type="com.apirone.core.model.bean.SignageConfigItem[]";
    property name="lineModel" type="com.apirone.core.model.bean.LineModel";

    public Status function init(){

        return this;
    }

}
