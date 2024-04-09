component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="status"    type="com.apirone.core.model.bean.Status";
    property name="parentId"  type="String";
    property name="level"     type="Numeric";

    public ProductCategory function init(){

        return this;
    }

}