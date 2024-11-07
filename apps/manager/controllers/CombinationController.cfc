component extends="com.apirone.core.controller.AbsController" {

    function organize( event, rc, prc ){

        prc.title = "Combinazioni per le linee";

        //prc.jsScripts.add( "app-line" );

        prc.sizes = super.fire( "size.list" );
        prc.lines = super.fire( "line.list" );
        prc.finishes = super.fire( "AttributeValue.list", { attributeId = "FIN0001" } );

        event.setView("combination/organize");

    }

    function attributes( event, rc, prc ){

        prc.obj = super.fire("line.get", [rc.id] );

        prc.title="Modifica linea < #prc.obj.getName()# >";

        prc.sizes = super.fire("size.list" );
        prc.statusList = super.fire( "status.list", ["line"] );
        prc.finishes = super.fire( "AttributeValue.list", { attributeId = "FIN0001" } );

        prc.sizeId = prc.sizes[1].getId();
        
        prc.jsScripts.add( "app-attribute" );
        prc.jsScripts.add( "app-line-attributes" );

        prc.page["attributeStatusList"] = super.fire( "status.list", ["attribute"] );
        prc.page["lineId"] = rc.id;
        
        event.setView( "line/attributes" );

    }
    
}
