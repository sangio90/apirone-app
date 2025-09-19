<!-- filepath: s:\workspace\users\roberto\projects\apir\apps\apirone-app\code\com\apirone\core\model\bean\FrameCell.cfc -->
component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

    // Proprietà primarie
    property name="frameCellId" type="Numeric";
    property name="frameId" type="String";
    property name="row" type="Numeric";
    property name="col" type="Numeric";
    property name="value" type="String";
    
    function init() {
        variables.frameCellId = 0;
        variables.frameId = "";
        variables.row = 0;
        variables.col = 0;
        variables.value = "";
        
        this.memento = {
            defaultIncludes = ["frameCellId", "frameId", "row", "col", "value"]
        };
        
        return this;
    }
}