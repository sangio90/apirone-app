component extends="com.apirone.core.controller.AbsController" {

    function detail( event, rc, prc ){

        var combination = super.fire( "combination.get", [ rc.id ] );

        prc.size = combination.getSize();
        prc.line = combination.getLine();

        prc.title="Dimensione #combination.getSize().getCode()#, finitura #combination.getFinish().getName()#";
        prc.subtitle="Linea #combination.getLine().getName()#";

        prc.sizes = super.fire("size.list", { lineId = prc.line.getId() } );

        prc.statusList = super.fire( "status.list", ["line"] );
        prc.finishes = super.fire( "finish.list" );

        combinations = super.fire( "combination.list", { lineId = prc.line.getId() } );

        
        prc.jsScripts.add( "app-attribute-detail" );
        prc.jsScripts.add( "app-component" );
        prc.jsScripts.add( "app-combination" );

        prc.page["lineId"] = prc.line.getId();

        prc.page["combinationId"] = combination.getId();
        prc.page["combinations"] = combinations;
        prc.page["attributeStatusList"] = super.fire( "status.list", ["attribute"] );

        prc.page["categories"] = super.getCategoriesAsJSON();

        event.setView( "combination/detail" );

    }

}
