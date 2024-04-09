component extends="com.apirone.core.controller.AbsController" {

    function home( event, rc, prc ){

        event.setView( "main/home" );

    }

    function forCompanies( event, rc, prc ){

        event.setView( "main/for-companies" );

    }

    function forPartners( event, rc, prc ){

        event.setView( "main/for-partners" );

    }

    function contacts( event, rc, prc ){

        event.setView( "main/contacts" );

    }

}
