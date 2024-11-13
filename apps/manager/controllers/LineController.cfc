component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Linee";

        prc.lineCategories = super.fire( "lineCategory.list" );

        prc.jsScripts.add( "app-line" );

        event.setView("line/list");

    }

    function attributes( event, rc, prc ){

        var combinations = super.fire( "combination.list", { lineId = rc.id } );

        dump(DESerializeJSON( SerializeJSON ( combinations )) );

        if( combinations.len() ) {

            cflocation( url="/manager/lines/#rc.id#/combinations/#combinations[1].getId()#", addToken=false );

        } else {

            //setMessage( type="warning", message="Carica almeno una combinazione" );

            //TODO: show message
            cflocation( url="/manager/lines/#rc.id#/combinations?msg=first-load-combinations", addToken=false );

        }


    }
    
    function combinations( event, rc, prc ){

        prc.existingCombinations = [];
        prc.obj = super.fire("line.get", [rc.id] );

        prc.title="Combinazioni per la linea < #prc.obj.getName()# >";
        prc.page["line"]=prc.obj;

        prc.sizes = super.fire( "size.list" );
        prc.finishes = super.fire( "AttributeValue.list", { attributeId = "FIN0001" } );

        var combinationsList = super.fire( "combination.list", { lineId = rc.id } );
        
        for( var combination in combinationsList ) {
            prc.existingCombinations.add( "#combination.getSize().getId()#__#combination.getFinish().getId()#" );
        }

        prc.jsScripts.add( "app-line" );

        event.setView( "line/combinations" );

    }
    
}
