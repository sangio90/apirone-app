component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="line" type="com.apirone.core.model.bean.Line";
    property name="model" type="com.apirone.core.model.bean.Model";
    property name="productCategory" type="com.apirone.core.model.bean.ProductCategory";

    public LineModel function init(){

        return this;
    }

}
