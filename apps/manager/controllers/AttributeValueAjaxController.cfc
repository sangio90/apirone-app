component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.attributeId="___";

        var data = [];
        var dm = getDataMapper();

        var rows = super.fire( "AttributeValue.list", [ rc.attributeId ] );

    }

    function save( event, rc, prc ){
        
    }


}
