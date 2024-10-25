component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="texts" type="com.apirone.core.model.bean.Text[]";
    property name="status" type="com.apirone.core.model.bean.Status";

    public AttributeValue function init(){

        return this;
        
    }

}
