component extends="com.apirone.core.controller.AbsController" {

    function dashboard( event, rc, prc ){

        prc.title = "Dashboard";

        event.setView( "main/dashboard" );

    }

    function tmp( event, rc, prc ){

        prc.page["attributeStatusList"] = super.fire( "status.list", ["attribute"] );
        prc.page["categories"] = super.getCategoriesAsJSON();

        prc.jsScripts.add( "app-attribute-detail" );
        prc.jsScripts.add( "tests/app-attribute-test" );
        //prc.jsScripts.add( "app-component" );
        //prc.jsScripts.add( "app-product-test" );

        event.setView( "util/tmp" );

    }

}
