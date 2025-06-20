component extends="com.apirone.core.controller.AbsController" {

    function detail( event, rc, prc ){

        var combination = super.fire( "combination.get", [ rc.id ] );

        //dump(DESerializeJSON(SerializeJSON(combination.getSize())));
        //abort;

        prc.size = combination.getSize();
        prc.finish = combination.getFinish();
        prc.line = combination.getLine();

        prc.title="Dimensione #combination.getSize().getCode()#, finitura #combination.getFinish().getName()#";
        prc.subtitle="Linea #combination.getLine().getName()#";

        prc.sizes = super.fire("size.list", { lineId = prc.line.getId() } );
        //prc.finishes = super.fire("size.finish", { lineId = prc.line.getId() } );

        //dump( DESerializeJSON(SerializeJSON( prc.sizes )) )
        //abort;

        prc.statusList = super.fire( "status.list", ["line"] );
        prc.finishes = super.fire( "finish.list" );

        var combinations = super.fire( "combination.list", { lineId = prc.line.getId() } );

        prc.jsScripts.add( "app-attribute-detail" );
        prc.jsScripts.add( "app-component" );
        
        prc.jsScripts.add( "app-combination" );
        
        //per astrarlo, in futuro quando lavoreremo sui frutti
        //prc.jsScripts.add( "app-product-attribute-list" );

        prc.page["lineId"] = prc.line.getId();

        prc.page["combinationId"] = combination.getId();
        prc.page["combinations"] = combinations;
        prc.page["attributeStatusList"] = super.fire( "status.list", ["attribute"] );

        prc.page["categories"] = super.getCategoriesAsJSON();

        event.setView( "combination/detail" );

    }

    function items( event, rc, prc ){

        var data = [];
        var result = super.getResult();

        var items = super.fire("ProductItemCombination.calculate", { combinationId = rc.id } );
        
        //var items = super.fire("ProductItem.getTree", { combinationId = rc.id } );

        //var result = convertTree( items=items );

        event.setView( "combination/items" );

    }

    private Array function convertTree( required Array items ) {
		
        var result = [];

        for( thisItem in items ) {

            var row = super.getDataMapper().convert( thisItem, "ProductItemTree", true );
            
            if( !IsNull( thisItem?.getChildren() ) ) {
                row["children"] = convertTree( items=thisItem.getChildren() );
            }        
    
            ArrayAppend( result, row );
    
        }

		return result;
    
    }

}
