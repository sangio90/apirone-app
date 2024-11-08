component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="size" type="com.apirone.core.model.bean.Size";
    property name="line" type="com.apirone.core.model.bean.Line";
    property name="finish" type="com.apirone.core.model.bean.Finish";

    public Combination function init(){

        return this;
        
    }

}
