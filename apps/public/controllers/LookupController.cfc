component extends="com.apirone.core.controller.AbsController" {

    function datajs( event, rc, prc ){

        var result = {};
        var user = arguments.event.getValue( "User" );

        var countries = getAccessManager().exec( user, "geo.listCountries", { statusId = 'ACT' } ).getData();
        var texts = getAccessManager().exec( user, "I18n.list", { langId = 'it', forJs = true } );

        /*
            set by area
        */
        for ( var country in countries ) {

            var areadId = country.getArea().getId();

            if ( !StructKeyExists( result, areadId ) ) {
                result[ areadId ] = [];
            }

            result[ areadId ].add( {  'name' = country.getName(), 'id' = country.getId() } );

        }

        rc.countries = result;
        rc.texts = texts;

        event.setView( "lookup/datajs" ).noLayout();

    }
    
}
