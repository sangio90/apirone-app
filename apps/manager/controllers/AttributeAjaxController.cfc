component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var data = [];
        var result = super.getResult();
        var dm = getDataMapper();
        
        var rows = super.fire( "attribute.list" );

        for ( var row in rows ) {
            var obj = dm.convert( row, "Line", true );
            data.add( obj );
        }

        result.setTotal( data.len() );
        result.setData( data );

        event.renderData( data=result, contentType="text/json", type="json" );
        
    }

    function new( event, rc, prc ){

        var texts = [];
        var langs = super.fire("lang.list");
        
        var attribute = super.bean( "Attribute" );

        attribute.setId("");

        for( var lang in langs ) {

            var text = super.bean( "Text" );
            
            text.setId( "" );
            text.setName( "" );
            
            text.setLang( lang );

            texts.add( text );

        }

        attribute.setTexts( texts );

        event.setValue("result", attribute);
        
    }

}
