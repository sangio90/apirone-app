component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Linee";

        prc.jsScripts.add( "app-line" );

        event.setView("line/list");

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
        
        event.setView( "line/attributes" );

    }
    
}
