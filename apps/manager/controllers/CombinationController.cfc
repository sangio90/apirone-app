component extends="com.apirone.core.controller.AbsController" {

    function detail( event, rc, prc ){

        var comb = super.fire( "combination.get", [ rc.id ] );

        var lineId = comb.getLine().getId();

        prc.title="Dimensione #comb.getSize().getName()#, finitura #comb.getFinish().getName()#";
        prc.subtitle="Linea #comb.getLine().getName()#";

        prc.sizes = super.fire("size.list", { lineId = lineId } );

        prc.statusList = super.fire( "status.list", ["line"] );
        prc.finishes = super.fire( "finish.list" );

        combinations = super.fire( "combination.list", { lineId = lineId } );

        prc.sizeId = comb.getSize().getId();
        
        prc.jsScripts.add( "app-attribute" );
        prc.jsScripts.add( "app-combination" );
        prc.jsScripts.add( "app-component" );

        prc.page["lineId"] = lineId;
        prc.page["combinationId"] = comb.getId();
        prc.page["combinations"] = combinations;
        prc.page["attributeStatusList"] = super.fire( "status.list", ["attribute"] );
        prc.page["categories"] = super.getCategoriesAsJSON();

        event.setView( "combination/detail" );

    }

}
