component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Linee";

        prc.jsScripts.add( "app-line" );

        event.setView("line/list");

    }

    /*
    function edit( event, rc, prc ){

        prc.obj = super.fire("line.get", [rc.id] );

        prc.title="Modifica linea < #prc.obj.getName()# >";

        prc.statusList = DESerializeJSON( FileRead( "/config/data/fake/status.json.cfm" ) );
        prc.priceLists = DESerializeJSON( FileRead( "/config/data/fake/pricelists.json.cfm" ) );
        
        prc.sizes = super.fire("size.list" );
        prc.thicknesses = super.fire( "lookup.list", ["thickness"] );

        prc.jsScripts.add( "app-line-detail" );

        event.setView( "line/detail" );

    }
    */
    
    function attributes( event, rc, prc ){

        prc.obj = super.fire("line.get", [rc.id] );

        prc.title="Modifica linea < #prc.obj.getName()# >";

        prc.sizes = super.fire("size.list" );
        prc.statusList = super.fire("status.list", ["line"] );
        prc.thicknesses = super.fire( "lookup.list", ["thickness"] );

        prc.sizeId = prc.sizes[1].getId();
        
        prc.jsScripts.add( "app-attribute" );
        prc.jsScripts.add( "app-line-attributes" );
        
        event.setView( "line/attributes" );

    }
    
}
