component extends="com.apirone.core.controller.AbsController" {

    function detail( event, rc, prc ){

        prc.obj = super.fire( "line.get", [rc.lineId] );

        prc.title="Modifica linea < #prc.obj.getName()# >";

        prc.sizes = super.fire("size.list" );
        prc.statusList = super.fire( "status.list", ["line"] );
        prc.finishes = super.fire( "attributeValue.list", { attributeId = "FIN0001" } );

        prc.sizeId = prc.sizes[1].getId();
        
        prc.jsScripts.add( "app-attribute" );
        prc.jsScripts.add( "app-combination" );

        prc.page["attributeStatusList"] = super.fire( "status.list", ["attribute"] );
        prc.page["lineId"] = rc.LineId;
        
        event.setView( "combination/detail" );

    }

}
