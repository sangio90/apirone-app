<!-- filepath: s:\workspace\users\roberto\projects\apir\apps\apirone-app\code\com\apirone\core\model\bean\Frame.cfc -->
component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

    // Proprietà primarie
    property name="frameId" type="String";
    property name="frame" type="String";
    property name="code" type="String";
    property name="orientationId" type="String";
    property name="cellOrientationId" type="String";
    
    // Proprietà per relazioni
    property name="cells" type="array";
    
    function init() {
        variables.frameId = "";
        variables.frame = "";
        variables.code = "";
        variables.orientationId = "";
        variables.cellOrientationId = "";
        variables.cells = [];
        
        this.memento = {
            defaultIncludes = ["frameId", "frame", "code", "orientationId", "cellOrientationId"],
            profiles = {
                list = {
                    defaultIncludes = ["frameId", "frame", "code", "orientationId", "cellOrientationId"]
                },
                detail = {
                    defaultIncludes = ["frameId", "frame", "code", "orientationId", "cellOrientationId", "cells"]
                }
            }
        };
        
        return this;
    }
}