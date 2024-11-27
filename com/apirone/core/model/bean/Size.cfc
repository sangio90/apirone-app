component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true"{

    property name="fruitsCount" type="Numeric";
    property name="code" type="String";
    property name="categories" type="com.apirone.core.model.bean.ProductCategory[]";
    property name="status" type="com.apirone.core.model.bean.Status";

    public Size function init(){

        return this;
    }

}
