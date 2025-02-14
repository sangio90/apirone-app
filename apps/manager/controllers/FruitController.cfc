component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Frutti";
        prc.statuses = super.fire( "status.list", ["FRUIT"] );

        prc.jsScripts.add( "app-fruit" );

        prc.page["statuses"] = prc.statuses;

        event.setView("fruit/list");

    }

    /*
    function get( event, rc, prc ){

        var user = prc.user;

        prc.title = "Frutto";

        prc.jsScripts.add( 'app-fruit' );

        event.setView('fruit/detail');

    }
    */

    function detail( event, rc, prc ){

        prc.fruit = super.fire( "fruit.get", [ rc.id ] );

        prc.title = "Frutto #prc.fruit.getCode()#";

        prc.statusList = super.fire( "status.list", ["line"] );

        prc.jsScripts.add( "app-component" );
        prc.jsScripts.add( "app-attribute-detail" );
        prc.jsScripts.add( "app-fruit" );

        prc.page["fruitId"] = prc.fruit.getId();

        prc.page["attributeStatusList"] = super.fire( "status.list", ["attribute"] );

        event.setView( "fruit/detail" );

    }

}
