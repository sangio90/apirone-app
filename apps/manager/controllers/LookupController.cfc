component extends="com.apirone.core.controller.AbsController" {

    function datajs( event, rc, prc ){

        var result = {};
        var user = arguments.event.getValue( "User" );

        prc.structData = {
            "shipmentTypes" = getAccessManager().exec( user, "lookup.list", [ 'shipmentType' ] ),
            "statusList" = getAccessManager().exec( user, "status.list", [ 'account' ] ).getData(),
            "roles" = getAccessManager().exec( user, "lookup.list", [ 'role' ] ),
            "capacities" = getAccessManager().exec( user, "capacity.list" ).getData()
        }

        event.setView( "util/data.js" ).noLayout();

    }
    
}
