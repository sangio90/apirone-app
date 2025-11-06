component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = prc.user;

        // // geo
        // prc.countries = getAccessManager().exec( user, "geo.listCountries" ).getData();

        // // lookup
        // prc.liquidTypes = getAccessManager().exec( user, "lookup.list", { entity = "liquidType" } );
        // prc.bottleCapacities = getAccessManager().exec( user, "lookup.list", { entity = "capacity" } );
        
        // //prc.foodOptions = getAccessManager().exec( user, "option.list", { areaId = 'F' } );
        // prc.wineOptions = getAccessManager().exec( user, "option.list", { areaId = 'W' } ).getData();


		prc.jsFiles.add( "app-country" );

        prc.title = "Nazioni";

        event.setView( "country/list" );

    }
    
}
