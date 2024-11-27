component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true"{

    property name="code" type="String";
    property name="status" type="com.apirone.core.model.bean.Status";
    property name="categories" type="com.apirone.core.model.bean.ProductCategory[]";

    public Finish function init(){

        return this;
    
    }

}
