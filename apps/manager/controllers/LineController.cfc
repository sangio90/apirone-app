component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Linee";

        prc.jsScripts.add( "app-line" );

        event.setView("line/list");

    }
    
    function edit( event, rc, prc ){

        prc.obj = super.fire("line.get", [rc.id] );

        prc.title="Modifica linea < #prc.obj.getName()# >";

        prc.statusList = DESerializeJSON( FileRead( '/config/data/fake/status.json.cfm' ) );
        prc.priceLists = DESerializeJSON( FileRead( '/config/data/fake/pricelists.json.cfm' ) );
        
        prc.sizes = super.fire("size.list" );
        prc.thicknesses = super.fire( "lookup.list", ["thickness"] );

        prc.jsScripts.add( "app-line-detail" );

        event.setView( "line/detail" );

    }

    function components( event, rc, prc ){

        prc.title = "Configurazione per " & super.fire("line.get", [ rc.lineId ]).getName();

        prc.sizes = super.fire("size.list" );

        prc.units        = DESerializeJSON( FileRead( '/config/data/fake/units.json.cfm' ) );
        prc.statusList   = DESerializeJSON( FileRead( '/config/data/fake/status.json.cfm' ) );
        prc.priceLists   = DESerializeJSON( FileRead( '/config/data/fake/pricelists.json.cfm' ) );
        prc.components   = DESerializeJSON( FileRead( '/config/data/fake/components.json.cfm' ) );
        prc.products     = DESerializeJSON( FileRead( '/config/data/fake/products.json.cfm' ) );
        prc.rawMaterials = DESerializeJSON( FileRead( '/config/data/fake/rawMaterials.json.cfm' ) );
        prc.colors       = DESerializeJSON( FileRead( '/config/data/fake/colors.json.cfm' ) );
        prc.variants     = DESerializeJSON( FileRead( '/config/data/fake/variants.json.cfm' ) );
        prc.works        = DESerializeJSON( FileRead( '/config/data/fake/works.json.cfm' ) );
        prc.finishes        = DESerializeJSON( FileRead( '/config/data/fake/finishes.json.cfm' ) );

        prc.jsScripts.add( "app-line-components" );

        event.setView( "line/components" );

    }    
    
}
