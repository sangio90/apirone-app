component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = arguments.event.getValue( "User" );

        // geo
        prc.countries = getAccessManager().exec( user, "geo.listCountries" ).getData();

        // lookup
        prc.liquidTypes = getAccessManager().exec( user, "lookup.list", { entity = "liquidType" } );
        prc.bottleCapacities = getAccessManager().exec( user, "lookup.list", { entity = "capacity" } );
        
        //prc.foodOptions = getAccessManager().exec( user, "option.list", { areaId = 'F' } );
        prc.wineOptions = getAccessManager().exec( user, "option.list", { areaId = 'W' } ).getData();

        prc.title = "Nazioni";

        event.setView( "country/list" );

    }
    
}
