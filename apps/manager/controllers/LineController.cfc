component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        prc.title = "Linee";

        prc.statuses = super.fire( "status.list", ["LINE"] );
        prc.thicknesses = super.fire( "lookup.list", [ "thickness" ] );
        prc.lineCategories = super.fire( "lineCategory.list" );

        prc.jsScripts.add( "app-line" );

        prc.page["statuses"] = prc.statuses;
        prc.page["thicknesses"] = prc.thicknesses;
        prc.page["categories"] = super.getCategoriesAsJSON();

        event.setView("line/list");

    }


    function attributes( event, rc, prc ){

        var combinations = super.fire( "combination.list", { lineId = rc.id } );

        if( combinations.len() ) {

            cflocation( url="/manager/combinations/#combinations[1].getId()#", addToken=false );

        } else {

            setMessage( type="warning", message="Carica almeno una combinazione" );

            //TODO: show message
            cflocation( url="/manager/lines/#rc.id#/combinations?msg=first-load-combinations", addToken=false );

        }

    }
    
    
    function combinations( event, rc, prc ){

        prc.existingCombinations = [];
        prc.line = super.fire("line.get", [rc.id] );

        prc.page["line"] = prc.line;
        prc.title = "Combinazioni per la linea < #prc.line.getName()# >";

        prc.sizes = super.fire( "size.list", { categoryId = prc.line.getCategory().getId() } );
        prc.finishes = super.fire( "finish.list", { categoryId = prc.line.getCategory().getId() } );

        var combinationsList = super.fire( "combination.list", { lineId = rc.id } );
        
        for( var combination in combinationsList ) {
            prc.existingCombinations.add( "#combination.getSize().getId()#__#combination.getFinish().getId()#" );
        }

        prc.jsScripts.add( "app-line" );

        event.setView( "line/combinations" );

    }
    
}
