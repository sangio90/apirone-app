component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true"{

    property name="status" type="com.apirone.core.model.bean.Status";
    property name="categories" type="com.apirone.core.model.bean.LineCategory[]";
	property name="values" type="com.apirone.core.model.bean.AttributeValue[]";

    public Attribute function init(){

        return this;
        
    }

}
