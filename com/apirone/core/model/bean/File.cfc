component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="kind" type="com.apirone.core.model.bean.FileKind";
    property name="size" type="Numeric";
    property name="width" type="Numeric";
    property name="height" type="Numeric";
    property name="alt" type="String";
    property name="extension" type="String";
    property name="description" type="String";
    property name="directory" type="String";
    property name="versions" type="Struct";
    property name="default" type="Boolean" default="false";

    public File function init(){

        return this;
    
    }

    public String function getPath() {

        return "#this.getDirectory()#/#this.getName()#"
    
    }

}