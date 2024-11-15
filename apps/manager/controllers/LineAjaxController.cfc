component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();

        var params = paramsFromUrl();

        var rows = super.fire( "line.list", params );

        for ( var row in rows ) {
            var obj = dm.convert( row, "Line", true );
            data.add( obj );
        }

        result.setTotal( data.len() );
        result.setCount( data.len() );
        result.setData( data );

        event.setValue("result", result);

    }

    function attributes( event, rc, prc ){

        param rc.str="";
        var result = super.getResult();

        var params = {}

        params.str = Len( rc.str ) ? rc.str : NullValue();

        var list = fire( "attributes.search", params );

        dump(list);
        abort;

        result = list;

        event.setValue("result", result);
        
    }

    function createCombination( event, rc, prc ){

        var json = DESerializeJSON( GetHTTPRequestData().content );

        var line = super.bean("Line");
        var size = super.bean("Size");
        var finish = super.bean("Finish");
        var combination = super.bean("Combination");

        combination.setLine( line.setId( rc.id ) );
        combination.setFinish( finish.setId( json.finishId ) );
        combination.setSize( size.setId( json.sizeId ) );
        
        var newId = super.fire( "combination.create", [ combination ] );

        var message = super.completeMessage( "combination.created" );

        var obj = super.fire( "combination.get", [ newId ] );

        event.setValue( "result", { 
            "message": message, 
            "payload" = { "combinationId" = newId, "finishId" = obj.getFinish().getId(), "sizeId" = obj.getSize().getId() }
        } );
        
    }

    function deleteCombination( event, rc, prc ){

        var json = DESerializeJSON( GetHTTPRequestData().content );

        super.fire( "combination.deleteByParams", { sizeId = json.sizeId, lineId = rc.id, finishId = json.finishId } );

        var message = super.completeMessage( "combination.deleted" );

        event.setValue( "result", { 
            "message": message, 
            //"payload" = { "combinationId" = newId, "finishId" = obj.getFinish().getId(), "sizeId" = obj.getSize().getId() }
        } );
        
    }

}
