component extends="com.apirone.core.controller.AbsController" {

    function detail( event, rc, prc ){

        var comb = super.fire( "combination.get", [ rc.id ] );

        var lineId = comb.getLine().getId();

        prc.title="Dimensione #comb.getSize().getName()#, finitura #comb.getFinish().getName()#";
        prc.subtitle="Linea #comb.getLine().getName()#";

        prc.sizes = super.fire("size.list", { lineId = lineId } );

        prc.statusList = super.fire( "status.list", ["line"] );
        prc.finishes = super.fire( "attributeValue.list", { attributeId = "FIN0001" } );

        prc.sizeId = comb.getSize().getId();
        prc.finishId = comb.getFinish().getId();
        
        prc.jsScripts.add( "app-attribute" );
        prc.jsScripts.add( "app-combination" );

        prc.page["attributeStatusList"] = super.fire( "status.list", ["attribute"] );
        prc.page["lineId"] = lineId;
        
        event.setView( "combination/detail" );

    }

}
