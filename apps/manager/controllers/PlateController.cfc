component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = prc.user;

        prc.title = "Placche";

        prc.list = DESerializeJSON( FileRead( '/config/data/fake/plates.json.cfm' ) );
        prc.statusList = DESerializeJSON( FileRead( '/config/data/fake/status.json.cfm' ) );

        prc.jsScripts.add( 'app-plate' );

        event.setView('plate/list');

    }
    
    function edit( event, rc, prc ){

        //addCommonData( prc );

        //prc.title="Modifica prodotto < #obj.getName()# >";
        prc.title="";
        prc.edit=true;

        prc.units = DESerializeJSON( FileRead( '/config/data/fake/units.json.cfm' ) );
        prc.statusList = DESerializeJSON( FileRead( '/config/data/fake/status.json.cfm' ) );

        prc.jsScripts.add( 'app-plate' );

        event.setView('plate/detail');

    }
    
}
