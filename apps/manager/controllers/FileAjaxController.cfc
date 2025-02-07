component extends="com.apirone.core.controller.AbsController" {

    function upload( event, rc, prc ){

        var tmpDir = getTempDir();
        var entity = super.bean("Entity");

        if( rc.by == "item" ) {
            entity.setKey( "combinationItemId" );
            entity.setValue( rc.itemId );
        }

        if( rc.by == "combination" ) {
            entity.setKey( "combinationId" );
            entity.setValue( rc.combinationId );
        }

		cffile( filefield=rc.files[1], nameconflict="MAKEUNIQUE", destination=tmpDir, action="UPLOAD" );

        super.fire( "file.create", {  filePath = "#tmpDir#/#cffile.ServerFile#", entity = entity } );

        var result = super.getResult();
        
        result.setData( { "message" = "File caricato" } );

        event.setValue( "result", result );
        
    }

    function list( event, rc, prc ){

        param rc.by = "____";
        var data = [];

        var item = {};

        var file = super.bean("Bean");

        if( rc.by == "combinations" ) {
            var params = { combinationId = rc.id }
            var config = getConfiguration().get("imagesConfig")[ "combination" ];
        }

        if( rc.by == "combination-items" ) {
            var params = { combinationItem = rc.id }
            var config = getConfiguration().get("imagesConfig")[ "combinationItem" ];
        }

        for( var kind in config.kinds  ) {

            params.put( "kindId", kind.id );

            var result = super.fire( "file.list", params );

            dump(result);

            if( result.getCount() ) {
                
                data.add( resul.getData()[1] );
            
            } else {

                data.add(
                    file.setDirectory("");
                    file.setName("");
                )

            }

        }

        dump(data);
        abort;
        
        dump(rc);
        abort;

        super.fire( "file.list", { params } );

        var result = super.getResult();
        
        result.setData( { "message" = "File caricato" } );

        event.setValue( "result", result );
        
    }

}



