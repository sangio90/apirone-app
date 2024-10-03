component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Placche";

        prc.jsScripts.add( "app-plate" );

        event.setView("plate/list");

    }
    
    function edit( event, rc, prc ){

        prc.obj = super.fire("line.get", [rc.id] );

        prc.title="Modifica linea < #prc.obj.getName()# >";

        prc.sizes = super.fire("size.list" );
        prc.thicknesses = super.fire( "lookup.list", ["thickness"] );

        prc.jsScripts.add( "app-line-detail" );

        event.setView( "line/detail" );
    
    }

}
