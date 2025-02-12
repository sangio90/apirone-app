component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.by = "____";
        var data = [];

        var item = {};

        var file = super.bean("File");

        if( rc.by == "combinations" ) {
            var params = { combinationId = rc.id }
            var config = getConfiguration().get("imagesConfig")[ "combination" ];
        }

        if( rc.by == "combination-items" ) {
            var params = { combinationItem = rc.id }
            var config = getConfiguration().get("imagesConfig")[ "combinationItem" ];
        }

        for( var type in config.types  ) {

            params.put("typeId", type.id )

            var images = super.fire( "file.list", params );

            // esiste l'immagine
            if( images.getCount() ) {

                var image = images.getData()[1];
                var json = DESerializeJSON( SerializeJSON( image ) );

                json["complete"] = true;


            // se non esiste, servo un'immagine vuota
            } else {

                var type = super.fire("fileType.get", [ type.id ] );

                file.setType( type );
                
                file.setId( "" );
                file.setName("");
                file.setDirectory("");

                var json = DESerializeJSON( SerializeJSON( file ) );

                json["complete"] = false;


            }

            data.add( json );

        }

        event.setValue( "result", data );
        
    }

    function upload( event, rc, prc ){

        var tmpDir = getTempDir();
        var entity = super.bean("Entity");
        var scope = "";

        if( rc.by == "combinations-items" ) {
            entity.setKey( "combinationItem.id" );
            scope = "combinationItem";
        }

        if( rc.by == "combinations" ) {
            entity.setKey( "combination.id" );
            scope = "combination";
        }

        entity.setValue( rc.id );

		cffile( filefield=rc.files[1], nameconflict="MAKEUNIQUE", destination=tmpDir, action="UPLOAD" );

        super.fire( "file.create", { filePath = "#tmpDir#/#cffile.ServerFile#", entity = entity, typeId=rc.typeId, scope=scope } );

        var result = super.getResult();
        
        var message = super.completeMessage( "file.imageCreated" );

        result.setData( { "message" = message, "payload" =  {} } );
        
        event.setValue( "result", result );
        
    }

}
