component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="status" type="com.apirone.core.model.bean.Status";
    property name="thickness" type="com.apirone.core.model.bean.Thickness";

    public Line function init(){

        return this;
        
    }

}
